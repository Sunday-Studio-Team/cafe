class_name TutorialView
extends Control

signal tutorials_finished(tutorial_view: TutorialView)

@export var _tutorial_screen_view_packed_scenes: Array[PackedScene]
@export var _tutorial_screen_container: Control

var _current_tutorial_view: TutorialScreenView
var _current_tutorial_index: int

func open_tutorial() -> void:
	show()
	_current_tutorial_index = 0
	_spawn_tutorial_screen_view()

func hide_tutorial() -> void:
	hide()

func _close_tutorial_screen_view() -> void:
	if _current_tutorial_view == null:
		return
	_current_tutorial_view.queue_free()
	_current_tutorial_view = null

func _spawn_tutorial_screen_view() -> void:
	_current_tutorial_view = _tutorial_screen_view_packed_scenes[_current_tutorial_index].instantiate()
	_tutorial_screen_container.add_child(_current_tutorial_view, true)
	_current_tutorial_view.finished.connect(_on_tutorial_screen_view_finished)

func _on_tutorial_screen_view_finished(tutorial_screen_view: TutorialScreenView) -> void:
	_close_tutorial_screen_view()
	if _current_tutorial_index + 1 >= _tutorial_screen_view_packed_scenes.size():
		tutorials_finished.emit(self)
	else:
		_current_tutorial_index += 1
		_spawn_tutorial_screen_view()
