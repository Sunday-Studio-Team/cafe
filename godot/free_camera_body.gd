class_name FreeCameraBody
extends CharacterBody3D

const MOUSE_SENSITIVITY_SCALING_FACTOR: float = 1000.0

@export var _player_ui_sub_viewport: SubViewport
@export var _mouse_sensitivity: float = 1.5
@export var _camera3D: Camera3D
@export var _base_fly_move_speed: float = 3.0
@export var _base_fly_sprint_move_speed_multiplier: float = 2.0

var _input_rotation: Vector3
var _mouse_input: Vector2
var _fly_move_speed: float = _base_fly_move_speed
var _fly_sprint_move_speed_multiplier: float = _base_fly_sprint_move_speed_multiplier
var _sprinting: bool = false

func _ready() -> void:
	Events.free_cam_toggled.connect(_on_free_cam_toggled)
	Events.free_cam_set_speed.connect(_on_free_cam_set_speed)

func _input(event: InputEvent) -> void:
	if !Global.free_camera_enabled:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not Global.in_ui:
		_mouse_input.x += -event.screen_relative.x * _mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR
		_mouse_input.y += -event.screen_relative.y * _mouse_sensitivity / MOUSE_SENSITIVITY_SCALING_FACTOR
	
	if Input.is_action_just_pressed("sprint"):
		_sprinting = true
	if Input.is_action_just_released("sprint"):
		_sprinting = false

func _physics_process(delta: float) -> void:
	if !Global.free_camera_enabled:
		return

	if Global.in_ui:
		return
	
	_handle_look()
	_handle_movement(delta)
	move_and_slide()


func _handle_look() -> void:
	_input_rotation.x = clampf(_input_rotation.x + _mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	_input_rotation.y += _mouse_input.x

	# rotate camera controller (up/down)
	_camera3D.transform.basis = Basis.from_euler(Vector3(_input_rotation.x, 0.0, 0.0))

	# rotate player (left/right)
	global_transform.basis = Basis.from_euler(Vector3(0.0, _input_rotation.y, 0.0))
	_mouse_input = Vector2.ZERO

func _handle_movement(delta: float) -> void:
	if Global.in_ui:
		velocity = Vector3.ZERO
		return
	
	var accel: float = Stats.current.player_accel
	var decel: float = Stats.current.player_decel
	
	# get the input direction (literally a Vector2 of the WASD/stick direction in x and y)
	var input_dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir_up_down: float = Input.get_axis("freecam_move_down", "freecam_move_up")
	
	# create a Vector3 of the the input_dir in 3D space
	var input_dir_3d := Vector3(input_dir_2d.x, input_dir_up_down, input_dir_2d.y)
	
	# multiply our input direction by our transform to get our rotated move direction in 3D space
	var move_dir_3d := transform.basis * input_dir_3d
	
	# get current velocity without Y so we dont do anything that messes with any gravity
	var new_velocity: Vector3 = Vector3(velocity.x, velocity.y, velocity.z)
	
	var move_speed: float
	if _sprinting:
		move_speed = _fly_move_speed * _fly_sprint_move_speed_multiplier
	else:
		move_speed = _fly_move_speed
	
	if move_dir_3d.length() > 0.2:
		new_velocity = new_velocity.move_toward(
				move_dir_3d * move_speed,
				accel * delta,
				)
	else:
		new_velocity = new_velocity.move_toward(Vector3.ZERO, decel * delta)

	# apply our horizontal velocity (but leave Y alone, the gravity func will handle that)
	velocity = Vector3(new_velocity.x, new_velocity.y, new_velocity.z)

func _on_free_cam_toggled() -> void:
	Global.free_camera_enabled = !Global.free_camera_enabled
	if Global.free_camera_enabled:
		var player_camera: Camera3D = Global.player.camera.camera_effects
		global_position = player_camera.global_position
		global_rotation = Vector3(player_camera.global_rotation.x, Global.player.global_rotation.y, player_camera.global_rotation.z)
		_input_rotation = global_rotation
		Global.player.free_cam_visualizer.visible = true
		_player_ui_sub_viewport.view_count = 0
		_camera3D.make_current()
	else:
		Global.player.free_cam_visualizer.visible = false
		_player_ui_sub_viewport.view_count = 1
		Global.player.camera.camera_effects.make_current()

func _on_free_cam_set_speed(speed: float) -> void:
	_fly_move_speed = _base_fly_move_speed * speed
