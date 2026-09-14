class_name TutorialManager
extends Node

@export var _tutorial_popups_manager: TutorialPopupsManager
@export var _cinematic_camera: CinematicCamera

@export var _day_0_sato_front_door_position: Node3D
@export var _day_0_employee_area_detector: PlayerDetectionArea
@export var _day_0_locker_room_preview_position: Node3D

var is_in_skippable_cinematic: bool = false

func _init() -> void:
	Global.tutorial_manager = self

func start_day() -> void:
	
	if Global.day == 0:
		# TEMPORARY WHILE REWORKING
		if true:
			Global.day = 1
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
			return
		
		is_in_skippable_cinematic = true

		_cinematic_camera.enable_cinematic_camera(0.0)
		_cinematic_camera.cinematic_bars.show_bars(0.0)
		await _cinematic_camera.play_animation("day_0_intro_0_0")
		await _cinematic_camera.play_animation("day_0_intro_0_1")
		await _cinematic_camera.play_animation("day_0_intro_0_2")
		await _cinematic_camera.play_animation("day_0_intro_0_3")
		await _cinematic_camera.play_animation("day_0_intro_0_4")
		await _cinematic_camera.play_animation("day_0_intro_0_5")

		Global.player.override_position_rotation(_day_0_sato_front_door_position.global_position, _day_0_sato_front_door_position.global_rotation)

		_cinematic_camera.play_animation("day_0_intro_1_0")
		await Global.voice_line_system.play_voice_line("day_0_intro_1_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_5", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_6", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		await Global.voice_line_system.play_voice_line("day_0_intro_1_8", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

		_cinematic_camera.play_animation("day_0_intro_2_0")
		await Global.voice_line_system.play_voice_line("day_0_intro_2_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
		if true:
			var tween_to_player: Tween = create_tween()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 2.0)
			tween_to_player.set_parallel()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 2.0)
		_cinematic_camera.cinematic_bars.hide_bars(2.0)
		await _cinematic_camera.disable_cinematic_camera(2.0)
		
		is_in_skippable_cinematic = false
		
		await _day_0_employee_area_detector.player_entered_area

		is_in_skippable_cinematic = true

		_cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
		_cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
		_cinematic_camera.enable_cinematic_camera(0.5)
		_cinematic_camera.cinematic_bars.show_bars(0.5)
		if true:
			var tween_to_player: Tween = create_tween()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_position", _day_0_locker_room_preview_position.global_position, 2.0)
			tween_to_player.set_parallel()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_rotation", _day_0_locker_room_preview_position.global_rotation, 2.0)

		await Global.voice_line_system.play_voice_line("day_0_intro_3_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

		if true:
			var tween_to_player: Tween = create_tween()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 2.0)
			tween_to_player.set_parallel()
			tween_to_player.tween_property(_cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 2.0)
		_cinematic_camera.cinematic_bars.hide_bars(2.0)
		await _cinematic_camera.disable_cinematic_camera(2.0)
		
		is_in_skippable_cinematic = false
		
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
