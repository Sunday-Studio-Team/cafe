class_name PlayerUiSubViewportContainer
extends SubViewportContainer

var _allow_input: bool = true

func set_allow_input(allow_input: bool) -> void:
	_allow_input = allow_input
	
	if _allow_input:
		mouse_target = false
	else:
		mouse_target = true

func _propagate_input_event(event: InputEvent) -> bool:
	return _allow_input
