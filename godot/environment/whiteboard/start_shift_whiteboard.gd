class_name StartShiftWhiteboard
extends Node3D

@export var _days_whiteboard_content_packed_scenes: Array[PackedScene]
@export var _fallback_day_whiteboard_content_packed_scene: PackedScene

@export var _content_parent_node: Node3D

func _ready() -> void:
	var day: int = Global.day
	var index: int = day - 1
	var day_whiteboard_content_packed_scene: PackedScene
	if index >= _days_whiteboard_content_packed_scenes.size():
		push_error("No whiteboard for day. Using fallback.")
		day_whiteboard_content_packed_scene = _fallback_day_whiteboard_content_packed_scene
	else:
		day_whiteboard_content_packed_scene = _days_whiteboard_content_packed_scenes[index]
	
	var day_whiteboard_content: DayShiftWhiteboardContent = day_whiteboard_content_packed_scene.instantiate()
	_content_parent_node.add_child(day_whiteboard_content)
