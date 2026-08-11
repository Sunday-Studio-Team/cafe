@tool
class_name PolygonCounterExtendedDock
extends Control

signal requested_check_all_meshes

const _finished_results_message: StringName = &"Checked all meshes!"
const _copied_to_clipboard_message: StringName = &"Copied to clipboard!"

@export var _check_all_meshes_button: Button
@export var _progress_bar: ProgressBar
@export var _clear_results_button: Button
@export var _copy_to_clipboard_button: Button
@export var _results_text_edit: TextEdit

func _ready() -> void:
	_check_all_meshes_button.pressed.connect(_on_check_all_meshes_button_pressed)
	_clear_results_button.pressed.connect(_on_clear_results_button_pressed)
	_copy_to_clipboard_button.pressed.connect(_on_copy_to_clipboard_button_pressed)
	_results_text_edit.editable = false
	_progress_bar.visible = false

func show_results(results: String) -> void:
	_results_text_edit.text = results
	var editor_toaster: EditorToaster = EditorInterface.get_editor_toaster()
	editor_toaster.push_toast(_finished_results_message)
	_set_buttons_enabled(true)
	_progress_bar.visible = false

func update_progress_bar(progress_ratio: float) -> void:
	_progress_bar.max_value = 1.0
	_progress_bar.min_value = 0.0
	_progress_bar.value = progress_ratio

func _on_check_all_meshes_button_pressed() -> void:
	_set_buttons_enabled(false)
	_progress_bar.visible = true
	requested_check_all_meshes.emit()

func _on_clear_results_button_pressed() -> void:
	_results_text_edit.text = ""

func _on_copy_to_clipboard_button_pressed() -> void:
	var results_text: String = _results_text_edit.text
	DisplayServer.clipboard_set(results_text)
	var editor_toaster: EditorToaster = EditorInterface.get_editor_toaster()
	editor_toaster.push_toast(_copied_to_clipboard_message)

func _set_buttons_enabled(enabled: bool) -> void:
	_check_all_meshes_button.disabled = !enabled
	_clear_results_button.disabled = !enabled
	_copy_to_clipboard_button.disabled = !enabled
