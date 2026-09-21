@tool
class_name Whiteboard
extends Node3D

@export var sub_viewport: SubViewport

@export var whiteboard_ui_scenes: Array[PackedScene]

var current_child:WhiteboardUI

@export_range(0,5) var day_test: int

@export_tool_button("Get Whiteboard") var action = tool_script_replace_ui
@export_tool_button("Show Day 5 Tippy") var action2 = show_tippy
@export_tool_button("Hide Day 5 Tippy") var action3 = hide_tippy

func _ready() -> void:
	for child in sub_viewport.get_children():
		child.queue_free()
	if not Engine.is_editor_hint():
		replace_ui(Global.day)
	else:
		replace_ui(day_test)

func tool_script_replace_ui():
	replace_ui(day_test)

func replace_ui(day:int):
	assert(day >= 0 and day <= 5, "Day is not in-between 0 and 5")
	current_child = null
	for child in sub_viewport.get_children():
		child.queue_free()
	current_child = whiteboard_ui_scenes[day].instantiate()
	sub_viewport.add_child(current_child)

func hide_tippy():
	if not Engine.is_editor_hint() and Global.day == 5 and current_child is Day5WhiteboardUI:
		(current_child as Day5WhiteboardUI).tippy.hide()
	elif day_test == 5:
		(current_child as Day5WhiteboardUI).tippy.hide()

func show_tippy():
	if not Engine.is_editor_hint() and Global.day == 5 and current_child is Day5WhiteboardUI:
		(current_child as Day5WhiteboardUI).tippy.show()
	elif day_test == 5:
		(current_child as Day5WhiteboardUI).tippy.show()
