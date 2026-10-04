class_name TippyTablet3D
extends Node3D

@export var clock_tutorial_indicator: Node3D
@export var money_and_goal_tutorial_indicator: Node3D
@export var rating_tutorial_indicator: Node3D

func _ready() -> void:
	hide_all_indicators()

func hide_all_indicators() -> void:
	clock_tutorial_indicator.visible = false
	money_and_goal_tutorial_indicator.visible = false
	rating_tutorial_indicator.visible = false