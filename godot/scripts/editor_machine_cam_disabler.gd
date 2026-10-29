@tool
class_name EditorMachineCamDisabler
extends Node

@export var _should_disable_cam_updates_in_editor: bool = true
@export var _sub_viewport: SubViewport

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and _should_disable_cam_updates_in_editor:
		if _sub_viewport == null:
			return
		_sub_viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_DISABLED
