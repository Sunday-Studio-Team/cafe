class_name PlayerUiSubViewportContainer
extends SubViewportContainer

signal allow_input_changed(allow_input: bool)

var _allow_input: bool = true

func set_allow_input(allow_input: bool) -> void:
	if allow_input != _allow_input:
		allow_input_changed.emit(allow_input)
	
	_allow_input = allow_input	
	
	if _allow_input:
		mouse_target = false
	else:
		mouse_target = true

func _propagate_input_event(_event: InputEvent) -> bool:
	return _allow_input
