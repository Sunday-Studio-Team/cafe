@tool
class_name EditorToolsEditorPlugin
extends EditorPlugin

static var _instance: EditorToolsEditorPlugin

static func get_instance() -> EditorToolsEditorPlugin:
	return _instance

func _enable_plugin() -> void:
	var stats_enum_generator: EditorToolsStatsEnumGenerator = EditorToolsStatsEnumGenerator.get_instance()
	stats_enum_generator.initialize()
	print("EditorToolsEditorPlugin started.")	

func _disable_plugin() -> void:
	var stats_enum_generator: EditorToolsStatsEnumGenerator = EditorToolsStatsEnumGenerator.get_instance()
	stats_enum_generator.deinitialize()
	print("EditorToolsEditorPlugin stopped.")

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_instance = self

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		_instance = null
