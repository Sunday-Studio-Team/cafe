class_name TutorialScreenView
extends Control

signal finished(tutorial_screen_view: TutorialScreenView)

@export var _continue_buttons: Array[TextureButton]


func _ready() -> void:
	for continue_button in _continue_buttons:
		if continue_button:
			# Prevents buttons from snatching input focus from the keyboard
			continue_button.focus_mode = Control.FOCUS_NONE
			continue_button.pressed.connect(_on_continue_button_pressed)
	

func _on_continue_button_pressed() -> void:
	finished.emit(self)
