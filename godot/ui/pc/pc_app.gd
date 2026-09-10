class_name PCApp
extends Control

@export var x_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_button.pressed.connect(_on_x_button_pressed)

func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed("pause") and visible:
		_on_x_button_pressed()
		get_viewport().set_input_as_handled()

func _on_x_button_pressed() -> void:
	hide()
