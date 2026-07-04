class_name Player
extends CharacterBody3D

const ACCELERATION := 25.0
const DECELERATION := 25.0
const STRIDE_LENGTH := 0.75

@export var camera: Camera3D
@export var aiming_ray: RayCast3D
@export var movement_enabled: bool = true
@export var ingredients_bag: MeshInstance3D

# this is a var separate to the const cos it changes when sprint etc
var move_speed: float = Stats.current.default_move_speed
var mouse_sens := 0.1
# the mouse's movement since the last physics frame .
# we get mouse input from _unhandled_input() which is called continuously, so
# we store it here then apply it in the physics process so no movement is
# applied off-sync with physics frames
var mouse_delta: Vector2 = Vector2.ZERO
# vars for footstep sounds
var pos_last_physics_frame: Vector3
var dist_travelled_since_last_step: float
var holding_interactable: bool = false

# we add on top of the ray distance to avoid weird stuff with big interactables
# (whose 'position's may be further away from us than their interactable hitbox)
# NOTE: if we start getting weird flickering while holding interactables, we
# might have to increase this a bit more
@onready var max_interact_dist: float = abs(aiming_ray.target_position.z) + 1.25


func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# the aiming ray is a child of the camera (not a direct child of the player)
	# so just enabling exclude_parent doesnt work
	aiming_ray.add_exception(self)


func _physics_process(delta: float) -> void:
	handle_mouselook()
	handle_hovered_interactable()
	handle_inspected_shelf_item()
	handle_sprint()
	handle_movement(delta)
	handle_gravity(delta)
	#handle_footstep_sounds()
	#tilt_camera()
	move_and_slide()
	handle_ingredients_bag_visibility()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_delta += event.screen_relative * mouse_sens


func handle_mouselook() -> void:
	camera.rotation_degrees.x -= mouse_delta.y
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

	rotation_degrees.y -= mouse_delta.x

	mouse_delta = Vector2.ZERO


func handle_movement(delta: float) -> void:
	#TO BE REMOVED: For testing the active item use
	if Input.is_action_just_pressed("Test_Button"):
		Events.active_item_used.emit("clock")
	
	if (
		not movement_enabled
		or holding_interactable
		or Global.minigame_active
		or Global.in_pc_ui
	):
		velocity = Vector3.ZERO
		return
	# get the input direction (literally a Vector2 of the WASD/stick direction in x and y)
	var input_dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# create a Vector3 of the the input_dir in 3D space
	var input_dir_3d := Vector3(input_dir_2d.x, 0, input_dir_2d.y)

	# multiply our input direction by our transform to get our rotated move direction in 3D space
	var move_dir_3d := transform.basis * input_dir_3d

	# get current velocity without Y so we dont do anything that messes with any gravity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if move_dir_3d.length() > 0.2:
		horizontal_velocity = horizontal_velocity.move_toward(move_dir_3d * move_speed, ACCELERATION * delta)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, DECELERATION * delta)

	# apply our horizontal velocity (but leave Y alone, the gravity func will handle that)
	velocity = Vector3(horizontal_velocity.x, velocity.y, horizontal_velocity.z)


func handle_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta


func handle_hovered_interactable() -> void:
	holding_interactable = false
	var hovered_interactable: Interactable = Global.hovered_interactable

	# if we're somehow hovering an interactable which has been disabled,
	# deleted or moved far away, fix that
	if hovered_interactable != null:
		if (
			not hovered_interactable.enabled
			or not hovered_interactable.is_inside_tree()
			or hovered_interactable.global_position.distance_to(camera.global_position) > max_interact_dist
		):
			Global.hovered_interactable = null

	# if we're currently holding interact on something, dont do anything
	# (so we can look around while we hold)
	if (
		hovered_interactable != null
		and hovered_interactable.hold_to_interact
		and Input.is_action_pressed("interact")
	):
		holding_interactable = true
		return

	var collider = aiming_ray.get_collider()
	if collider is Interactable:
		Global.hovered_interactable = collider
	else:
		Global.hovered_interactable = null

	if Global.minigame_active:
		Global.hovered_interactable = null


func handle_inspected_shelf_item() -> void:
	var collider = aiming_ray.get_collider()
	if collider is ShelfItem:
		Global.inspected_shelf_item = collider
	else:
		Global.inspected_shelf_item = null


func handle_sprint() -> void:
	if Input.is_action_pressed("sprint"):
		move_speed = Stats.current.sprint_move_speed
	else:
		move_speed = Stats.current.default_move_speed


# (unfinished) plays footstep sounds with timing adjusted to speed
func handle_footstep_sounds() -> void:
	if get_last_motion() == Vector3.ZERO:
		dist_travelled_since_last_step = 0
	else:
		dist_travelled_since_last_step += global_position.distance_to(pos_last_physics_frame)

	if dist_travelled_since_last_step >= STRIDE_LENGTH:
		# TODO: play sound
		dist_travelled_since_last_step = 0

	pos_last_physics_frame = global_position


func tilt_camera() -> void:
	const TILT_AMOUNT := 0.25

	var local_velocity = basis.transposed() * velocity
	camera.rotation_degrees.z = -local_velocity.x * TILT_AMOUNT


func handle_ingredients_bag_visibility() -> void:
	ingredients_bag.visible = Global.holding_ingredients






func _on_area_3d_body_entered(body):
	print(body)
	pass # Replace with function body.



func _on_area_3d_area_entered(area):
	print(area)
	pass # Replace with function body.
