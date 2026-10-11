class_name LowFpsSubViewportUpdater
extends Node

@export var _sub_viewport: SubViewport
@export var _target_frames_per_second: int = 10

var _delta_since_last_frame: float
var _delay_frames_remaining: int = 0

func _enter_tree() -> void:
	Global.low_fps_updaters.append(self)

func _ready() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _process(delta: float) -> void:
	if _delay_frames_remaining > 0:
		return
	
	_delta_since_last_frame += delta
	var seconds_per_frame: float = 1.0 / _target_frames_per_second
	if _delta_since_last_frame >= seconds_per_frame:
		_update_sub_viewport()
		_delta_since_last_frame = 0.0

func set_delay(delay_frames: int):
	_delay_frames_remaining = delay_frames
	
	while _delay_frames_remaining > 0:
		await get_tree().process_frame
		_delay_frames_remaining -= 1
	

func _update_sub_viewport() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
