class_name TutorialManager
extends Node

signal finished_tutorial

@export var _tutorial_view_canvas_layer: CanvasLayer
@export var _tutorial_view: TutorialView


func _ready() -> void:
	_tutorial_view.tutorials_finished.connect(_on_tutorials_finished)


func show_tutorial() -> void:
	Global.in_tutorial_screen = true
	_tutorial_view.open_tutorial()

func show_tutorial_intro_screen() -> void:
	Global.in_tutorial_screen = true
	_tutorial_view.show_tutorial_intro_screen()
	

func _on_tutorials_finished(tutorial_view: TutorialView) -> void:
	tutorial_view.hide_tutorial()
	Global.in_tutorial_screen = false
	finished_tutorial.emit()
