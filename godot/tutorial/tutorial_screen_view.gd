class_name TutorialScreenView
extends Control

signal finished(tutorial_screen_view: TutorialScreenView)

@export var _continue_buttons: Array[TextureButton]


func _ready() -> void:
	for continue_button in _continue_buttons:
		continue_button.pressed.connect(_on_continue_button_pressed)


func _on_continue_button_pressed() -> void:
	finished.emit(self)
