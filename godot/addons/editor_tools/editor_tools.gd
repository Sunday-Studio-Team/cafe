@tool
class_name EditorToolsEditorPlugin
extends EditorPlugin

static var _instance: EditorToolsEditorPlugin

static func get_instance() -> EditorToolsEditorPlugin:
	return _instance

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_instance = self
		var stats_enum_generator: EditorToolsStatsEnumGenerator = EditorToolsStatsEnumGenerator.get_instance()
		stats_enum_generator.initialize()
		print("EditorToolsEditorPlugin started.")

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		var stats_enum_generator: EditorToolsStatsEnumGenerator = EditorToolsStatsEnumGenerator.get_instance()
		stats_enum_generator.deinitialize()
		print("EditorToolsEditorPlugin stopped.")
		_instance = null
