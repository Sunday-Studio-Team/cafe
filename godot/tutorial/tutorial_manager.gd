class_name TutorialManager
extends Node

@export var _tutorial_popups_manager: TutorialPopupsManager

var is_in_skippable_cinematic: bool = false

func _init() -> void:
	Global.tutorial_manager = self

func start_day() -> void:
	
	if Global.day == 0:
		# TEMPORARY WHILE REWORKING
		Global.day = 1
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
		return
		
		# is_in_skippable_cinematic = true
	elif Global.day == 1:
		pass
	elif Global.day == 2:
		pass
	elif Global.day == 3:
		pass
	elif Global.day == 4:
		pass
	elif Global.day == 5:
		pass
	
