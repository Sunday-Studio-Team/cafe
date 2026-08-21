class_name DialogOptionView
extends Control

signal selected_option(dialog_option_view: DialogOptionView)

@export var _option_text_label: RichTextLabel
@export var _button: Button

var _dialog_option: DialogOption

func setup(dialog_option: DialogOption) -> void:
	_dialog_option = dialog_option
	_option_text_label.text = dialog_option.option_text
	_button.pressed.connect(_on_button_pressed)

func get_option() -> DialogOption:
	return _dialog_option

func _on_button_pressed() -> void:
	selected_option.emit(self)
