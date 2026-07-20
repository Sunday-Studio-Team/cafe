class_name PauseMenu
extends CanvasLayer

signal tutorial_requested

@export var _continue_button: Button
@export var _tutorial_button: Button
@export var restart_button: Button
@export var quit_button: Button

var in_end_screen := false

func _ready() -> void:
	_continue_button.pressed.connect(_unpause)
	_tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	quit_button.pressed.connect(func(): Events.main_menu_loaded.emit())
	restart_button.pressed.connect(
		func():
			visible = false
			get_tree().paused = false
			Global.day = 1
			Events.main_scene_loaded.emit()
	)
	Events.time_up.connect(
		func():
			in_end_screen = true
	)


func _physics_process(_delta: float) -> void:
	if (
			Input.is_action_just_pressed("pause")
			and not Global.in_ui
	):
		_unpause()


func _unpause() -> void:
	get_tree().paused = !get_tree().paused
	visible = !visible

func _on_tutorial_button_pressed() -> void:
	tutorial_requested.emit()
