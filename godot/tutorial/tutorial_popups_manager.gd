class_name TutorialPopupsManager
extends Node

signal finished_popups

@export var _popup_tutorial_view: PopupTutorialView

func _ready() -> void:
	_popup_tutorial_view.popup_tutorials_finished.connect(_on_popups_finished)

func show_intro_and_controls_popups() -> void:
	Global.in_popup_tutorial_screen = true
	_popup_tutorial_view.show_intro_and_controls_popups()

func show_all_handbook_popups() -> void:
	Global.in_popup_tutorial_screen = true
	_popup_tutorial_view.show_all_handbook_popups()

func _on_popups_finished(popup_tutorial_view: PopupTutorialView) -> void:
	popup_tutorial_view.hide_popup()
	Global.in_popup_tutorial_screen = false
	finished_popups.emit()
