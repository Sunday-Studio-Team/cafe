@tool
class_name OptionsMenuKeybindOptionView
extends Control

signal rebound_action(keycode: Key)

@export var action_name: String:
	get:
		if _action_name_label == null:
			return ""
		return _action_name_label.text
	set(value):
		if _action_name_label == null:
			return
		_action_name_label.text = value
	
@export var _action_name_label: RichTextLabel
@export var _reset_button: Button
@export var _keybind_label: RichTextLabel
@export var _rebind_button: Button
@export var _rebind_popup_packed_scene: PackedScene

var _action_name: StringName
var _default_physical_keycode: Key
var _current_physical_keycode: Key
var _rebind_popup: OptionsMenuActionRebindPopup

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		_rebind_button.pressed.connect(_on_rebind_button_pressed)
		_reset_button.pressed.connect(_on_reset_button_pressed)

func set_action(action_label_text: String, action_name: StringName) -> void:
	_action_name_label.text = action_label_text
	_action_name = action_name

func set_default_keybind(physical_keycode: Key) -> void:
	_default_physical_keycode = physical_keycode
	_update_reset_button()

func set_current_keybind(physical_keycode: Key) -> void:
	_current_physical_keycode = physical_keycode
	var keybind_string = OS.get_keycode_string(physical_keycode)
	print("current physical_keycode: %s" % keybind_string)
	_keybind_label.text = keybind_string
	_update_reset_button()

func _on_rebind_button_pressed() -> void:
	_rebind_popup = _rebind_popup_packed_scene.instantiate()
	add_child(_rebind_popup, true)
	_rebind_popup.setup(_action_name_label.text)
	_rebind_popup.key_pressed.connect(_on_rebind_popup_key_pressed)

func _on_rebind_popup_key_pressed(physical_keycode: Key) -> void:
	set_current_keybind(physical_keycode)
	rebound_action.emit(physical_keycode)
	_rebind_popup.close_popup()

func _on_reset_button_pressed() -> void:
	set_current_keybind(_default_physical_keycode)
	rebound_action.emit(_default_physical_keycode)

func _update_reset_button() -> void:
	if _default_physical_keycode != _current_physical_keycode:
		_reset_button.visible = true
	else:
		_reset_button.visible = false
