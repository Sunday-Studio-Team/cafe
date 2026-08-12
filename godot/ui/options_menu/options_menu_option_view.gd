@tool
class_name OptionsMenuOptionView
extends Control

signal changed_option(index: int)

@export var option_name: String:
	get:
		if _option_label == null:
			return ""
		return _option_label.text
	set(value):
		if _option_label == null:
			return
		_option_label.text = value
	
@export var _option_label: RichTextLabel
@export var _option_button: OptionButton

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		_option_button.item_selected.connect(_on_item_selected)

func set_label(label_text: String) -> void:
	_option_label.text = label_text

func set_dropdown_options(options_dict: Dictionary[String, int]) -> void:
	_hide_all_buttons()
	_option_button.visible = true
	_option_button.clear()
	for option_entry_name in options_dict.keys():
		_option_button.add_item(option_entry_name)

func set_selected_dropdown_option(index: int) -> void:
	_option_button.selected = index

func _hide_all_buttons() -> void:
	_option_button.visible = false

func _on_item_selected(index: int) -> void:
	changed_option.emit(index)
