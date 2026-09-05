class_name TutorialScreenView
extends Control
@onready var texture_rect: TextureRect = $TextureRect

signal finished(tutorial_screen_view: TutorialScreenView)

@export var _continue_buttons: Array[TextureButton]


func _ready() -> void:
	var image = texture_rect.texture.get_image()
	#var data = image.get_data()
	#data.lock()
	var pixel = image.get_pixel(1,2)
	print(pixel)
	for continue_button in _continue_buttons:
		continue_button.pressed.connect(_on_continue_button_pressed)


func _on_continue_button_pressed() -> void:
	finished.emit(self)
