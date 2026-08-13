extends Node3D
class_name SecurityCam3D

@export var ray: RayCast3D
@export var spotlight: SpotLight3D
@export var rotation_amount: float = 90
@export var rotation_time: float = 3
@export var rotation_pause_length: float = 2
@export var timer: Timer
@export var interactable : Interactable
# safe reference for when we use this item on a camera
@export var whipped_cream_item: Item
@export var tries_until_disabled: int = 3

# we duplicate the raycast many times to cover the spotlight cone on startup
# so we store a ref to all the rays here to iterate over them
var all_rays: Array[RayCast3D]
var rotate_tween: Tween
var disable_minigames := ["Lines"]
var _camera_disarmed := false

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
			if Input.is_action_pressed("sprint") and Global.player.get_last_motion() != Vector3.ZERO:
				timer.start()
				Global.score_update_message = "caught running"
				Global.employee_rating -= Stats.current.penalty_for_running
			elif Global.making_drink_manually:
				timer.start()
				Global.score_update_message = "caught making drink by hand"
				Global.employee_rating -= Stats.current.penalty_for_handmade_drink
			elif (
				Global.holding_ingredients and Global.holding_ingredients_rule
			):
				Global.score_update_message = "caught stealing ingredients"
				Global.employee_rating -= Stats.current.penalty_for_holding_ingredients
				timer.start()

			player_in_spotlight = true
			break

# we need both a local and global var here to track if the player is in this
# spotlight AND if theyre in ANY spotlight (otherwise we'd start getting weird
# things like this light flashing red when we enter a separate cameara's fov)
	if player_in_spotlight:
		spotlight.light_color = Color.RED
		Global.player_in_cctv_los = true
		Global.player_in_cctv_los_camera = self
		if Input.is_action_just_pressed("interact") and Global.player_in_cctv_los_camera == self and not Global.owned_items.any(func(x: Item): return x.name == "Whipped Cream"):
			open_camera_minigame()
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
	if item != null and item == whipped_cream_item:
		Global.deactivate_active_item(whipped_cream_item)
		disarm_camera()
		await get_tree().create_timer(8, false).timeout
		rearm_camera()
