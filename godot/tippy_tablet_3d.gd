class_name TippyTablet3D
extends Node3D

@export var money_tutorial_indicator: Node3D
@export var money_goal_tutorial_indicator: Node3D
@export var rating_tutorial_indicator: Node3D

func _ready() -> void:
	hide_all_indicators()

func hide_all_indicators() -> void:
	money_tutorial_indicator.visible = false
	money_goal_tutorial_indicator.visible = false
	rating_tutorial_indicator.visible = false
