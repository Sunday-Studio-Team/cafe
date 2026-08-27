class_name SecurityCam3D
extends Node3D

const NUM_OF_MINIGAMES_TO_DISABLE := 1

@export var _shape_cast_3d: ShapeCast3D
@export var spotlight: SpotLight3D
@export var camera_aimer_node: Node3D
@export var aim_path_follow_3d: PathFollow3D
@export var aim_follow_rate: float = 0.5
@export var rotation_amount: float = 90
@export var rotation_time: float = 3
@export var rotation_pause_length: float = 2
@export var grace_timer: Timer
@export var disabled_timer: Timer
@export var interactable: Interactable
@export var caught_audio_stream_player_3d: AudioStreamPlayer3D
@export var disable_sound: AudioStreamPlayer3D
@export var disable_particles: GPUParticles3D
@export var disabled_timer_sprite: Sprite3D
@export var disabled_timer_bar: TextureProgressBar

# we duplicate the raycast many times to cover the spotlight cone on startup
# so we store a ref to all the rays here to iterate over them
var _all_shape_casts: Array[ShapeCast3D]
var rotate_tween: Tween
var disable_minigames := ["Lines"]
var _camera_disarmed := false
var _player_slow_status_effect: CameraSlowPlayerStatusEffect
var _direction_multiplier: float = 1.0

@onready var original_rotation := rotation_degrees
@onready var tries_until_disabled := NUM_OF_MINIGAMES_TO_DISABLE


func _ready() -> void:
	create_rays()

	interactable.interacted.connect(open_camera_minigame)
	interactable.used_active_item.connect(_on_used_active_item)

	visibility_changed.connect(_on_visibility_changed)
	_update_camera_components_active()

	# Randomize progress along path
	aim_path_follow_3d.progress_ratio = randf_range(0.0, 1.0)
	# Randomize direction multiplier
	var direction_roll: float = randf_range(0.0, 1.0)
	if direction_roll >= 0.5:
		_direction_multiplier = 1.0
	else:
		_direction_multiplier = -1.0

	get_stats()
	Events.items_updated.connect(get_stats)
	interactable.visible = false
	Events.shift_started.connect(
		func():
			interactable.visible = true,
	)


func get_stats() -> void:
	disabled_timer.wait_time = Stats.current.time_camera_disabled_after_sabotage


func _physics_process(_delta: float) -> void:
	disabled_timer_sprite.visible = not disabled_timer.is_stopped()
	disabled_timer_bar.value = 100 - disabled_timer.time_left / disabled_timer.wait_time * 100

	if not visible or _camera_disarmed:
		return

	if not grace_timer.is_stopped():
		spotlight.light_color = Color.DIM_GRAY
		return

	var player_in_spotlight := false

	for shape_cast in _all_shape_casts:
		var collision_count: int = shape_cast.get_collision_count()
		if collision_count >= 0:
			for i in range(collision_count):
				var collider: Object = shape_cast.get_collider(i)
				if collider == Global.player:
					var apply_slow: bool = false
					if Global.player.is_sprinting() and Global.player.get_last_motion() != Vector3.ZERO:
						grace_timer.start()
						Events.alert_posted.emit("caught running")
						apply_slow = true
					elif Global.making_drink_manually:
						grace_timer.start()
						Events.alert_posted.emit("caught making drink by hand")
						if Global.machine_in_use != null:
							Global.machine_in_use.blast_player_from_using_machine()
						apply_slow = true

					if apply_slow:
						if _player_slow_status_effect != null:
							Global.player.player_status_effects.remove_status_effect(_player_slow_status_effect)
						_player_slow_status_effect = CameraSlowPlayerStatusEffect.new(self, Stats.current.camera_slow_player_duration)
						Global.player.player_status_effects.apply_status_effect(_player_slow_status_effect)
						caught_audio_stream_player_3d.play()
					player_in_spotlight = true
					break

				elif collider == Global.tippy_boss:
					if Global.tippy_boss.state == TippyBoss.State.CHASING:
						Global.tippy_boss.set_state(TippyBoss.State.ZAPPED)
						grace_timer.start()
						break

	if player_in_spotlight:
		spotlight.light_color = Color.RED
		Global.player_in_cctv_los = true
	else:
		spotlight.light_color = Color.WHITE

	# commenting cos it only takes 1 minigame to disable for now
	#interactable.display_name = "sabotage camera (%s steps left)" % tries_until_disabled

	aim_path_follow_3d.progress += _delta * aim_follow_rate * _direction_multiplier
	camera_aimer_node.look_at(aim_path_follow_3d.global_position)


func _on_visibility_changed() -> void:
	_update_camera_components_active()


func disarm_camera() -> void:
	_camera_disarmed = true
	disable_sound.play()
	disable_particles.emitting = true
	_update_camera_components_active()


func rearm_camera() -> void:
	_camera_disarmed = false
	_update_camera_components_active()


func _update_camera_components_active() -> void:
	if visible and not _camera_disarmed:
		interactable.visible = true
		spotlight.visible = true
		_shape_cast_3d.enabled = true
		for stored_ray in _all_shape_casts:
			stored_ray.enabled = true
	else:
		interactable.visible = false
		spotlight.visible = false
		_shape_cast_3d.enabled = false
		for stored_ray in _all_shape_casts:
			stored_ray.enabled = false


# duplicates our raycast many times, covering roughly the area of the spotlight
func create_rays() -> void:
	# we need to overshoot slightly to account for the sorta
	# halo around the edge of the light
	#const ANGLE_OVERSHOOT := 5.0
	_all_shape_casts.append(_shape_cast_3d)
	# Disable the template by default.
	# ray.enabled = false
	# for x_rot in range(25, 360, 15):
	# 	for z_rot in range(5, spotlight.spot_angle + ANGLE_OVERSHOOT, 5):
	# 		var new_ray := ray.duplicate() as RayCast3D
	# 		new_ray.rotation_degrees.x += x_rot
	# 		new_ray.rotation_degrees.z += z_rot
	# 		spotlight.add_child(new_ray)
	# 		all_rays.append(new_ray)


func try_disable_camera() -> void:
	if _camera_disarmed:
		return

	tries_until_disabled -= 1
	if tries_until_disabled <= 0:
		disarm_camera()
		tries_until_disabled = NUM_OF_MINIGAMES_TO_DISABLE
		disabled_timer.start()
		await disabled_timer.timeout
		rearm_camera()


func open_camera_minigame() -> void:
	if _camera_disarmed:
		return

	if Global.minigame_active:
		return

	Events.minigame_end.connect(_on_break_camera)
	Events.minigame_cancelled.connect(_cancel_break_minigame)
	Events.minigame_active.emit(disable_minigames.pick_random())


func _on_break_camera() -> void:
	Events.minigame_end.disconnect(_on_break_camera)
	Events.minigame_cancelled.disconnect(_cancel_break_minigame)
	try_disable_camera()


func _cancel_break_minigame() -> void:
	Events.minigame_end.disconnect(_on_break_camera)
	Events.minigame_cancelled.disconnect(_cancel_break_minigame)


func _on_used_active_item(item: Item):
	if item != null and item.item_id == "whipped_cream":
		Global.put_active_item_on_cooldown(item)
		disarm_camera()
		disabled_timer.wait_time = 15
		disabled_timer.start()
		await disabled_timer.timeout
		disabled_timer.wait_time = Stats.current.time_camera_disabled_after_sabotage
		rearm_camera()
