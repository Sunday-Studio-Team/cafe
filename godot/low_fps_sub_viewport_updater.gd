class_name LowFpsSubViewportUpdater
extends Node

@export var _sub_viewport: SubViewport
@export var _target_frames_per_second: int = 10

var _delta_since_last_frame: float

func _ready() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _process(delta: float) -> void:
	_delta_since_last_frame += delta
	var seconds_per_frame: float = 1.0 / _target_frames_per_second
	if _delta_since_last_frame >= seconds_per_frame:
		_update_sub_viewport()
		_delta_since_last_frame = 0.0

func _update_sub_viewport() -> void:
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
