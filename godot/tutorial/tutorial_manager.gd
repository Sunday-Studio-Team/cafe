class_name TutorialManager
extends Node

signal finished_tutorial

@export var _tutorial_view_canvas_layer: CanvasLayer
@export var _tutorial_view: TutorialView


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Fixes pause blocking
	if _tutorial_view:
		_tutorial_view.tutorials_finished.connect(_on_tutorials_finished)


func _process(_delta: float) -> void:
	if Global.in_tutorial_screen and Input.is_action_just_pressed("pause"):
		escape_tutorial(_tutorial_view)


func show_tutorial() -> void:
	_open_layer()
	_tutorial_view.open_tutorial()


func show_intro_tutorial() -> void:
	_open_layer()
	_tutorial_view.show_tutorial_intro_screen()


func show_machine_tutorial() -> void:
	_open_layer()
	_tutorial_view.show_machine_tutorial_screen()


func escape_tutorial(tutorial_view: TutorialView) -> void:
	_close_tutorial(tutorial_view)


func _on_tutorials_finished(tutorial_view: TutorialView) -> void:
	_close_tutorial(tutorial_view)


func _open_layer() -> void:
	Global.in_tutorial_screen = true
	if _tutorial_view_canvas_layer:
		_tutorial_view_canvas_layer.show()


func _close_tutorial(tutorial_view: TutorialView) -> void:
	if tutorial_view:
		tutorial_view.hide_tutorial()
	if _tutorial_view_canvas_layer:
		_tutorial_view_canvas_layer.hide()
	Global.in_tutorial_screen = false
	finished_tutorial.emit()
