class_name CameraController
extends Node3D

const MOUSE_SENSITIVITY_SCALING_FACTOR: float = 1000.0

#values
@export var player_controller: Player
@export var mouse_sensitivity_at_min: float = 0.1
@export var mouse_sensitivity_at_max: float = 3.0
@export var camera_effects: Camera3D

var input_rotation: Vector3
var mouse_input: Vector2


func _input(event: InputEvent) -> void:
	if Global.free_camera_enabled:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not Global.in_ui:
		
		var options_mouse_sensitivity: float = SaveDataManager.get_options_data().mouse_sensitivity
		var mouse_sensitivity: float
		mouse_sensitivity = remap(options_mouse_sensitivity, OptionsData.MOUSE_SENSITIVITY_MIN, OptionsData.MOUSE_SENSITIVITY_MAX, mouse_sensitivity_at_min, mouse_sensitivity_at_max)
		
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR

func _physics_process(_delta: float) -> void:
	if Global.free_camera_enabled:
		return
	
	if Global.in_ui:
		return

	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x

	# rotate camera controller (up/down)
	transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))

	# rotate player (left/right)
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	mouse_input = Vector2.ZERO

func sync_rotation_from_player() -> void:
	input_rotation.y = player_controller.global_rotation.y
	input_rotation.x = rotation.x
	mouse_input = Vector2.ZERO
