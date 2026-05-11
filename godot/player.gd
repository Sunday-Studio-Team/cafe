# NOTE: this is mostly copied from another project so probably has some
# unused stuff
#	- jack
class_name Player
extends CharacterBody3D

const ACCELERATION := 25.0
const DECELERATION := 25.0
const MOVE_SPEED := 2.5
const STRIDE_LENGTH := 0.75

@export var camera: Camera3D

var mouse_sens := 0.1
# the mouse's movement since the last physics frame .
# we get mouse input from _unhandled_input() which is called continuously, so
# we store it here then apply it in the physics process so no movement is
# applied off-sync with physics frames
var mouse_delta: Vector2 = Vector2.ZERO
# vars for footstep sounds
var pos_last_physics_frame: Vector3
var dist_travelled_since_last_step: float

@onready var hands: Area3D = %Hands


func _ready() -> void:
	Global.player = self
	#Global.player_hands = hands
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	handle_mouselook()
	handle_movement(delta)
	handle_gravity(delta)
	handle_footstep_sounds()
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_delta += event.screen_relative * mouse_sens
	
	if event is InputEventMouseButton and event.button_mask == 1:
		print(event)


func handle_mouselook() -> void:
	camera.rotation_degrees.x -= mouse_delta.y
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

	rotation_degrees.y -= mouse_delta.x

	mouse_delta = Vector2.ZERO


func handle_movement(delta: float) -> void:
	# get the input direction (literally a Vector2 of the WASD/stick direction in x and y)
	var input_dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# create a Vector3 of the the input_dir in 3D space
	var input_dir_3d := Vector3(input_dir_2d.x, 0, input_dir_2d.y)

	# multiply our input direction by our transform to get our rotated move direction in 3D space
	var move_dir_3d := transform.basis * input_dir_3d

	# get current velocity without Y so we dont do anything that messes with any gravity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if move_dir_3d.length() > 0.2:
		horizontal_velocity = horizontal_velocity.move_toward(move_dir_3d * MOVE_SPEED, ACCELERATION * delta)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, DECELERATION * delta)

	# apply our horizontal velocity (but leave Y alone, the gravity func will handle that)
	velocity = Vector3(horizontal_velocity.x, velocity.y, horizontal_velocity.z)


func handle_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta


func handle_footstep_sounds() -> void:
	if get_last_motion() == Vector3.ZERO:
		dist_travelled_since_last_step = 0
	else:
		dist_travelled_since_last_step += global_position.distance_to(pos_last_physics_frame)

	if dist_travelled_since_last_step >= STRIDE_LENGTH:
		# TODO: play sound
		dist_travelled_since_last_step = 0

	pos_last_physics_frame = global_position
