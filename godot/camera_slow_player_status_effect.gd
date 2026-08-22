class_name CameraSlowPlayerStatusEffect 
extends PlayerStatusEffect

var _owner_camera: SecurityCam3D
var _duration: float
var _duration_remaining: float
var _expired: bool

func _init(owner_camera: SecurityCam3D, duration: float) -> void:
	_owner_camera = owner_camera
	_duration = duration
	_duration_remaining = _duration

func apply_effect(player: Player) -> void:
	player._walk_move_speed *= Stats.current.camera_slow_player_walk_speed_multiplier
	player._sprint_move_speed *= Stats.current.camera_slow_player_sprint_speed_multiplier

func process_status_effect(delta: float) -> void:
	_duration_remaining -= delta
	if _duration_remaining <= 0.0:
		_expired = true

func is_status_effect_expired() -> bool:
	return _expired

func get_owner() -> Object:
	return _owner_camera as Object
