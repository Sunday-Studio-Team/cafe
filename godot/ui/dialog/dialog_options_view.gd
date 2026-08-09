class_name DialogOptionsView
extends Control

signal selected_option

@export var _option_views_container: Control
@export var _dialog_option_view_packed_scene: PackedScene

var _dialog_option_views: Array[DialogOptionView] = []
var _selected_option: DialogOption

func show_options(dialog_event_options: DialogEventOptions) -> void:
	_clear_dialog_options()
	for dialog_option in dialog_event_options.dialog_options:
		var dialog_option_view: DialogOptionView = _dialog_option_view_packed_scene.instantiate()
		_dialog_option_views.append(dialog_option_view)
		dialog_option_view.setup(dialog_option)
		_option_views_container.add_child(dialog_option_view)
		dialog_option_view.selected_option.connect(_on_dialog_option_view_selected_option)

func get_selected_option() -> DialogOption:
	return _selected_option

func _on_dialog_option_view_selected_option(dialog_option_view: DialogOptionView) -> void:
	var dialog_option: DialogOption = dialog_option_view.get_option()
	_selected_option = dialog_option
	_clear_dialog_options()
	selected_option.emit()

func _clear_dialog_options() -> void:
	for view in _dialog_option_views:
		view.queue_free()
	_dialog_option_views.clear()
