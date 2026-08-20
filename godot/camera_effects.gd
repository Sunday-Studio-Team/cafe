class_name CameraEffects extends Camera3D

@export_category("Refecrences")
@export var player : Player
#easly turned off

@export_category("Effects")
@export var enable_tilt : bool = true
@export var enable_headbob : bool = true
@export var enable_shake: bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch : float = 0.1 
@export var run_roll : float = 0.20 
@export var max_pitch : float = 1.0 
@export var max_roll : float = 2.5 
@export_group("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch: float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll: float = 0.025
@export_range(0.0, 0.04, 0.001) var bob_up: float = 0.005
@export_range(3.0, 10.0, 0.1) var bob_frequency: float = 5.0

@export_group("Shake")
@export var max_shake: float = 5.0
@export	var shake_fade: float =5.0
var _shake_strength :float = 0.0 

var _step_timer : float = 0.0

func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)

func trigger_shake()-> void:
	_shake_strength = max_shake

func _physics_process(delta: float) -> void:
	camera_effects(delta)
	

func camera_effects(delta: float) -> void:
	if not player:
		return
	
	
	var velocity = player.velocity
	
	# Headbob Step Timer and Sin Value
	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1 and player.is_on_floor():
		_step_timer += delta * (speed / bob_frequency)
		_step_timer = fmod(_step_timer, 1.0)
	else:
		_step_timer = 0.0
	var bob_sin = sin(_step_timer * 2.0 * PI) * 0.5
	
	
	var angles = Vector3.ZERO
	var offset = Vector3.ZERO
	
	# Camera Tilt
	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt
		
		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt
	
	# Headbob
	if enable_headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta
		
		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta
		
		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height
	
	
	if enable_shake:
		if _shake_strength >0: 
			_shake_strength = lerp(_shake_strength, 0.0, shake_fade*delta)
			offset = Vector3(randf_range(-_shake_strength, _shake_strength) , randf_range(-_shake_strength, _shake_strength),0.0 )
	
	
	
	position = offset
	rotation = angles 

func _on_game_options_changed(options_data: OptionsData) -> void:
	match options_data.camera_motion_option:
		OptionsData.CameraMotionOption.On:
			enable_headbob = true
			enable_shake = true
			enable_tilt = true
		OptionsData.CameraMotionOption.Off:
			enable_headbob = false
			enable_shake = false
			enable_tilt = false
		_:
			pass
