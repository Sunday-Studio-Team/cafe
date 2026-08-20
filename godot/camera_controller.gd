class_name CameraController
extends Node3D

const MOUSE_SENSITIVITY_SCALING_FACTOR: float = 1000.0

#values
@export var player_controller: Player
@export var mouse_sensitivity: float = 1.5
var input_rotation: Vector3
var mouse_input: Vector2
@export var camera_effects: Camera3D

var use_interpolation: bool = false
var circle_strafe: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_controller = get_parent()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not Global.in_ui:
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR

func _physics_process(delta: float) -> void:
	if Global.in_ui:
		return

	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x

	# rotate camera controller (up/down)
	player_controller.camera_controller_anchor.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))

	# rotate player (left/right)
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	global_transform = player_controller.camera_controller_anchor.get_global_transform_interpolated()
	mouse_input = Vector2.ZERO

func sync_rotation_to_player() -> void:
	input_rotation.y = player_controller.global_rotation.y
	input_rotation.x = player_controller.camera_controller_anchor.rotation.x
	mouse_input = Vector2.ZERO
