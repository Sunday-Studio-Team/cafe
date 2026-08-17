class_name SecurityCam3D
extends Node3D

@export var ray: RayCast3D
@export var spotlight: SpotLight3D
@export var rotation_amount: float = 90
@export var rotation_time: float = 3
@export var rotation_pause_length: float = 2
@export var timer: Timer
@export var interactable : Interactable
# safe reference for when we use this item on a camera
@export var tries_until_disabled: int = 3
@export var caught_audio_stream_player_3d: AudioStreamPlayer3D

# we duplicate the raycast many times to cover the spotlight cone on startup
# so we store a ref to all the rays here to iterate over them
var all_rays: Array[RayCast3D]
var rotate_tween: Tween
var disable_minigames := ["Lines"]
var _camera_disarmed := false
var _player_slow_status_effect: Player.CameraSlowPlayerStatusEffect

@onready var original_rotation := rotation_degrees


func _ready() -> void:
	create_rays()

	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y + rotation_amount, rotation_time)
	rotate_tween.tween_interval(rotation_pause_length)
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y - rotation_amount, rotation_time)
	rotate_tween.tween_interval(rotation_pause_length)

	interactable.interacted.connect(open_camera_minigame)
	interactable.used_active_item.connect(_on_used_active_item)

	visibility_changed.connect(_on_visibility_changed)
	_update_camera_components_active()


func _physics_process(_delta: float) -> void:
	if not visible or _camera_disarmed:
		return

	if not timer.is_stopped():
		spotlight.light_color = Color.DIM_GRAY
		return

	var player_in_spotlight := false

	for r in all_rays:
		var collider = r.get_collider()
		if collider == Global.player:
			var apply_slow: bool = false
			if Input.is_action_pressed("sprint") and Global.player.get_last_motion() != Vector3.ZERO:
				timer.start()
				Events.alert_posted.emit("caught running")
				apply_slow = true
			elif Global.making_drink_manually:
				timer.start()
				Events.alert_posted.emit("caught making drink by hand")
				apply_slow = true
			elif Global.holding_ingredients and Global.holding_ingredients_rule:
				timer.start()
				Events.alert_posted.emit("caught stealing ingredients")
				apply_slow = true
			
			if apply_slow:
				if _player_slow_status_effect != null:
					Global.player.player_status_effects.remove_status_effect(_player_slow_status_effect)
				_player_slow_status_effect = Player.CameraSlowPlayerStatusEffect.new(self, Stats.current.camera_slow_player_duration)
				Global.player.player_status_effects.apply_status_effect(_player_slow_status_effect)
				caught_audio_stream_player_3d.play()
			player_in_spotlight = true
			break

	if player_in_spotlight:
		spotlight.light_color = Color.RED
		Global.player_in_cctv_los = true
	else:
		spotlight.light_color = Color.WHITE

	interactable.display_name = "sabotage camera (%s steps left)" % tries_until_disabled


func _on_visibility_changed() -> void:
	_update_camera_components_active()


func disarm_camera() -> void:
	_camera_disarmed = true
	_update_camera_components_active()


func rearm_camera() -> void:
	_camera_disarmed = false
	_update_camera_components_active()


func _update_camera_components_active() -> void:
	if visible and not _camera_disarmed:
		interactable.visible = true
		spotlight.visible = true
		rotate_tween.play()
		ray.enabled = true
		for stored_ray in all_rays:
			stored_ray.enabled = true
	else:
		interactable.visible = false
		spotlight.visible = false
		rotate_tween.stop()
		ray.enabled = false
		for stored_ray in all_rays:
			stored_ray.enabled = false



# duplicates our raycast many times, covering roughly the area of the spotlight
func create_rays() -> void:
	# we need to overshoot slightly to account for the sorta
	# halo around the edge of the light
	const ANGLE_OVERSHOOT := 5.0

	# Disable the template by default.
	ray.enabled = false
	for x_rot in range(25, 360, 15):
		for z_rot in range(5, spotlight.spot_angle + ANGLE_OVERSHOOT, 5):
			var new_ray := ray.duplicate() as RayCast3D
			new_ray.rotation_degrees.x += x_rot
			new_ray.rotation_degrees.z += z_rot
			spotlight.add_child(new_ray)
			all_rays.append(new_ray)


func try_disable_camera() -> void:
	if _camera_disarmed:
		return

	tries_until_disabled -= 1
	if tries_until_disabled <= 0:
		disarm_camera()
		await get_tree().create_timer(20, false).timeout
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
		var disarm_duration: float = 1.0
		if item.item_level == 1:
			disarm_duration = 10
		elif item.item_level == 2:
			disarm_duration = 20
		await get_tree().create_timer(disarm_duration, false).timeout
		rearm_camera()
