class_name OptionsMenuActionRebindPopup
extends Node

signal key_pressed(physical_keycode: Key)

@export var _action_name_label: RichTextLabel

func setup(action_name: StringName) -> void:
	_action_name_label.text = action_name

func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey:
		var input_event_key: InputEventKey = input_event as InputEventKey
		key_pressed.emit(input_event_key.physical_keycode)

func close_popup() -> void:
	queue_free()
