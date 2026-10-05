class_name SecurityCam3D
extends Node3D

const NUM_OF_MINIGAMES_TO_DISABLE := 1

@export var model: Node3D
@export var _shape_cast_3d: ShapeCast3D
## this is the spotlight that illuminates the circle the camera is watching
@export var spotlight: SpotLight3D
## this is the spotlight that comes out of the camera for effect
@export var fake_spotlight: SpotLight3D
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
@export var disable_2d_vfx: AnimatedSprite3D
@export var disabled_timer_sprite: Sprite3D
@export var disabled_timer_bar: TextureProgressBar
@export var whipped_cream_sound: AudioStreamPlayer

var rotate_tween: Tween
var _camera_disarmed := false
var _player_slow_status_effect: CameraSlowPlayerStatusEffect
var _direction_multiplier: float = 1.0
var _player_in_spotlight_tween: Tween


@onready var original_rotation := rotation_degrees
@onready var tries_until_disabled := NUM_OF_MINIGAMES_TO_DISABLE


func _ready() -> void:
	interactable.requested_use_active_item.connect(_on_requested_use_active_item)

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


func get_stats() -> void:
	disabled_timer.wait_time = Stats.current.time_camera_disabled_after_sabotage


func _physics_process(_delta: float) -> void:
	disabled_timer_sprite.visible = not disabled_timer.is_stopped()
	disabled_timer_bar.value = 100 - disabled_timer.time_left / disabled_timer.wait_time * 100

	if not visible or _camera_disarmed:
		return

	if not grace_timer.is_stopped():
		if _player_in_spotlight_tween and _player_in_spotlight_tween.is_running():
			_player_in_spotlight_tween.kill()
		spotlight.light_color = Color.DIM_GRAY
		fake_spotlight.light_color = Color.DIM_GRAY
		return

	var player_in_spotlight := false

	var collision_count: int = _shape_cast_3d.get_collision_count()
	if collision_count >= 0:
		for i in range(collision_count):
			var collider: Object = _shape_cast_3d.get_collider(i)
			if collider == Global.player:
				var rule_break: bool = false
				if (
					Global.player.is_sprinting()
					and Global.player.get_last_motion() != Vector3.ZERO
				):
					grace_timer.start(3)
					Global.add_alert(15)
					Events.alert_posted.emit("Caught running!", UI.AlertIconType.RULE_BREAK)
					rule_break = true
				elif Global.making_drink_manually:
					grace_timer.start(0.3)
					Global.add_alert(1)
					Events.alert_posted.emit(
						"Caught making drink by hand!",
						UI.AlertIconType.RULE_BREAK,
					)
					rule_break = true

				if rule_break:
					caught_audio_stream_player_3d.play()
					Global.player.flash_red()
					if Global.player_alert >= 100:
						Global.player_alert = 50
						if _player_slow_status_effect != null:
							Global.player.player_status_effects.remove_status_effect(
								_player_slow_status_effect
							)
						_player_slow_status_effect = CameraSlowPlayerStatusEffect.new(
							self,
							Stats.current.camera_slow_player_duration,
						)
						Global.player.player_status_effects.apply_status_effect(
							_player_slow_status_effect
						)
						if Global.machine_in_use != null:
							Global.machine_in_use.blast_player_from_using_machine()
				player_in_spotlight = true
				break

			elif collider == Global.tippy_boss:
				if Global.tippy_boss.state == TippyBoss.State.CHASING:
					Global.tippy_boss.set_state(TippyBoss.State.ZAPPED)
					grace_timer.start()
					break

	if player_in_spotlight:
		if not _player_in_spotlight_tween or not _player_in_spotlight_tween.is_running():
			_player_in_spotlight_tween = create_tween()
			_player_in_spotlight_tween.tween_property(spotlight, "light_color", Color.WHITE, 0.5).from(Color.RED)
			_player_in_spotlight_tween.tween_property(spotlight, "light_color", Color.RED, 0.5)
			_player_in_spotlight_tween.tween_property(fake_spotlight, "light_color", Color.WHITE, 0.5).from(Color.RED)
			_player_in_spotlight_tween.tween_property(fake_spotlight, "light_color", Color.RED, 0.5)
		#spotlight.light_color = Color.RED
		#fake_spotlight.light_color = Color.RED
		Global.player_in_cctv_los = true
	else:
		if _player_in_spotlight_tween and _player_in_spotlight_tween.is_running():
			_player_in_spotlight_tween.kill()
		spotlight.light_color = Color.RED
		fake_spotlight.light_color = Color.RED

	aim_path_follow_3d.progress += _delta * aim_follow_rate * _direction_multiplier
	camera_aimer_node.look_at(aim_path_follow_3d.global_position)


func _on_visibility_changed() -> void:
	_update_camera_components_active()


func disarm_camera() -> void:
	Global.locked_camera_target_pos = model.global_position
	Global.camera_mode = Global.CameraMode.LOCKED_TO_POINT
	_camera_disarmed = true
	disable_sound.play()
	disable_particles.emitting = true
	disable_2d_vfx.play()
	_update_camera_components_active()
	await Events.viewmodel_animation_finished
	Global.camera_mode = Global.CameraMode.PLAYER


func rearm_camera() -> void:
	_camera_disarmed = false
	_update_camera_components_active()


func _update_camera_components_active() -> void:
	if visible and not _camera_disarmed:
		interactable.visible = true
		spotlight.visible = true
		fake_spotlight.visible = true
		_shape_cast_3d.enabled = true
	else:
		interactable.visible = false
		spotlight.visible = false
		fake_spotlight.visible = false
		_shape_cast_3d.enabled = false



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





func _on_requested_use_active_item():
	var whipped_cream: Item = null
	for owned_item in Global.owned_items:
		if owned_item.item_id == "whipped_cream":
			whipped_cream = owned_item
			break

	if whipped_cream == null or !whipped_cream.can_be_used:
		return
	
	Events.play_viewmodel_animation.emit("cream_use")
	Global.put_active_item_on_cooldown(whipped_cream)
	await Events.whipped_cream_animation_shot
	whipped_cream_sound.play()
	disarm_camera()
	disabled_timer.wait_time = 15
	disabled_timer.start()
	await disabled_timer.timeout
	disabled_timer.wait_time = Stats.current.time_camera_disabled_after_sabotage
	rearm_camera()
