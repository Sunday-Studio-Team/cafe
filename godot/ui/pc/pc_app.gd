class_name PCApp
extends Control

@export var x_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_button.pressed.connect(_on_x_button_pressed)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and visible:
		_on_x_button_pressed()


func _on_x_button_pressed() -> void:
	hide()
