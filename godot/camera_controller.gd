class_name CameraController
extends Node3D

const MOUSE_SENSITIVITY_SCALING_FACTOR: float = 0.001
const MOUSE_SENSITIVITY_AT_MIN: float = 0.1
const MOUSE_SENSITIVITY_AT_MAX: float = 3.0

@export var player: Player
@export var camera_effects: CameraEffects

var mouse_sens_from_options: float

var input_rotation: Vector3
var mouse_input_since_last_physics_frame := Vector2.ZERO


func _ready() -> void:
	sync_rotation_from_player()
	
	mouse_sens_from_options = SaveDataManager.get_options_data().mouse_sensitivity
	Events.game_options_changed.connect(
			func(_options_data: OptionsData):
				mouse_sens_from_options = SaveDataManager.get_options_data().mouse_sensitivity
	)


func _unhandled_input(event: InputEvent) -> void:
	if Global.camera_mode != Global.CameraMode.PLAYER or Global.in_ui:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not Global.in_ui:
		var mouse_sens: float = remap(
				mouse_sens_from_options,
				OptionsData.MOUSE_SENSITIVITY_MIN,
				OptionsData.MOUSE_SENSITIVITY_MAX,
				MOUSE_SENSITIVITY_AT_MIN,
				MOUSE_SENSITIVITY_AT_MAX
	) * MOUSE_SENSITIVITY_SCALING_FACTOR
		
		mouse_input_since_last_physics_frame.x += -event.screen_relative.x * mouse_sens
		mouse_input_since_last_physics_frame.y += -event.screen_relative.y * mouse_sens


func _physics_process(delta: float) -> void:
	if Global.in_ui:
		return

	if Global.camera_mode == Global.CameraMode.PLAYER:
		input_rotation.x = clampf(input_rotation.x + mouse_input_since_last_physics_frame.y, deg_to_rad(-90), deg_to_rad(85))
		input_rotation.y += mouse_input_since_last_physics_frame.x

		# rotate camera controller (up/down)
		transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))

		# rotate player (left/right)
		player.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))

		mouse_input_since_last_physics_frame = Vector2.ZERO
	
	elif Global.camera_mode == Global.CameraMode.LOCKED_TO_POINT:
		const CAMERA_PAN_SPEED_MULTIPLIER := 10
		
		var direction_to_point: Vector3 = global_position.direction_to(Global.locked_camera_target_pos)
		var horizontal_direction_to_point := Vector3(direction_to_point.x, 0, direction_to_point.z)
		
		var desired_y_rotation := Vector3.FORWARD.signed_angle_to(horizontal_direction_to_point, Vector3.UP)
		player.global_rotation.y = lerp_angle(
				player.global_rotation.y,
				desired_y_rotation,
				delta * CAMERA_PAN_SPEED_MULTIPLIER
		)

		var desired_x_rotation := horizontal_direction_to_point.signed_angle_to(direction_to_point, global_transform.basis.x)
		global_rotation.x = lerp_angle(
				global_rotation.x,
				desired_x_rotation,
				delta * CAMERA_PAN_SPEED_MULTIPLIER
		)


func sync_rotation_from_player() -> void:
	input_rotation.y = player.global_rotation.y
	input_rotation.x = rotation.x
