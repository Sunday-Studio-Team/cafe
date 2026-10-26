class_name TippyTablet3D
extends Node3D

const FIRST_DAY_WITH_CAMERAS: int = 3

@export var money_tutorial_indicator: Node3D
@export var money_goal_tutorial_indicator: Node3D
@export var rating_tutorial_indicator: Node3D
@export var addon_model: Node3D


func _ready() -> void:
	# NOTE: i hid these in editor too just to see what i was doing with other
	#		stuff but feel free to re-show
	hide_all_indicators()

	if Global.day < FIRST_DAY_WITH_CAMERAS:
		addon_model.queue_free()


func hide_all_indicators() -> void:
	money_tutorial_indicator.visible = false
	money_goal_tutorial_indicator.visible = false
	rating_tutorial_indicator.visible = false
