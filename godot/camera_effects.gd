# this script goes on the player camera itself but only handles camera effects
# TODO: move it to a Node underneath the camera so the naming will be less confusing
# (theres a few places where we reference the object this script is attached to and it isnt
# obvious that we're referencing the camera itself)
class_name CameraEffects extends Camera3D

@export var player : Player
@export var caught_overlay: TextureRect

const BOB_MAGNITUDE: float = 10
const BOB_FREQUENCY: float = 3.0

# the weight for the lerp back to normal cam after the shake effect ends
const SHAKE_FADE_SPEED: float = 5.0
const MAX_SHAKE_AMOUNT: float = 1.0

const MAX_PITCH_DEGREES: float = 0.25
const MAX_ROLL_DEGREES: float = 0.25

var _current_shake_strength: float = 0.0

var enable_tilt: bool = true
var enable_shake: bool = true


func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)


func trigger_shake()-> void:
	_current_shake_strength = MAX_SHAKE_AMOUNT


func _physics_process(delta: float) -> void:
	var player_velocity: Vector3 = player.velocity
	var player_horizontal_velocity_length: float = Vector2(player_velocity.x, player_velocity.z).length()

	var rotation_offset_from_effects := Vector3.ZERO
	var position_offset_from_effects := Vector3.ZERO

	if enable_tilt:
		var global_forward_direction: Vector3 = -global_transform.basis.z
		var move_dir_to_forward_dir_dot: float = player_velocity.normalized().dot(global_forward_direction)

		var forward_tilt: float = remap(
				move_dir_to_forward_dir_dot * player_horizontal_velocity_length,
				-1,
				1,
				deg_to_rad(MAX_PITCH_DEGREES),
				deg_to_rad(-MAX_PITCH_DEGREES)
		)
		rotation_offset_from_effects.x += forward_tilt

		var global_right_direction: Vector3 = global_transform.basis.x
		var move_dir_to_right_dir_dot: float = player_velocity.dot(global_right_direction)

		var side_tilt: float = remap(
				move_dir_to_right_dir_dot * player_horizontal_velocity_length, 
				-1,
				1,
				deg_to_rad(-MAX_ROLL_DEGREES), 
				deg_to_rad(MAX_ROLL_DEGREES),
		)
		rotation_offset_from_effects.z -= side_tilt

	if enable_shake:
		if _current_shake_strength > 0:
			_current_shake_strength = lerp(_current_shake_strength, 0.0, SHAKE_FADE_SPEED*delta)
			position_offset_from_effects = Vector3(randf_range(-_current_shake_strength, _current_shake_strength) , randf_range(-_current_shake_strength, _current_shake_strength),0.0 )

		position = position_offset_from_effects
		rotation = rotation_offset_from_effects


func _on_game_options_changed(options_data: OptionsData) -> void:
	match options_data.camera_motion_option:
		OptionsData.CameraMotionOption.On:
			enable_shake = true
			enable_tilt = true
		OptionsData.CameraMotionOption.Off:
			enable_shake = false
			enable_tilt = false


func flash_screen_red():
	var t := create_tween()
	t.tween_property(caught_overlay, "modulate:a", 0.5, 0.2)
	t.tween_property(caught_overlay, "modulate:a", 0.0, 1.0)
