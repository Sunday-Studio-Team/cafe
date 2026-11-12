class_name LowFpsSubViewportUpdater
extends Node

@export var _sub_viewport: SubViewport
@export var _target_frames_per_second: int = 10

var _delta_since_last_frame: float
var _delay_frames_remaining: int = 0

var _enable_target_fps_override: bool = false
var _target_fps_override: int

func _enter_tree() -> void:
	Global.low_fps_updaters.append(self)

func _ready() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _process(delta: float) -> void:
	if _target_frames_per_second == 0:
		return
	
	if _delay_frames_remaining > 0:
		return
	
	_delta_since_last_frame += delta
	var target_fps: int
	if _enable_target_fps_override and _target_fps_override > 0:
		target_fps = _target_fps_override
	else:
		target_fps = _target_frames_per_second
	var seconds_per_frame: float = 1.0 / target_fps
	if _delta_since_last_frame >= seconds_per_frame:
		_update_sub_viewport()
		_delta_since_last_frame = 0.0

func set_delay(delay_frames: int):
	_delay_frames_remaining = delay_frames
	
	while _delay_frames_remaining > 0:
		await get_tree().process_frame
		_delay_frames_remaining -= 1	

func override_target_fps(fps_override: int) -> void:
	_enable_target_fps_override = true
	_target_fps_override = fps_override
	force_update_sub_viewport()

func clear_override_target_fps() -> void:
	_enable_target_fps_override = false
	force_update_sub_viewport()

func force_update_sub_viewport() -> void:
	_update_sub_viewport()

func _update_sub_viewport() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
