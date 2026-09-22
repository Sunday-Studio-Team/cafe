class_name SkippableTutorialPart
extends Node

enum TutorialPartEnum {
	DAY_0_0,
	DAY_0_1,
	DAY_0_2,
	DAY_0_3,
	DAY_0_4,
	DAY_0_5,
	DAY_0_6,
	DAY_0_7,
	DAY_0_8,
	DAY_0_9,
	DAY_1_0,
	DAY_1_1,
}

var finished_tutorial_part: bool = false

var _tutorial_manager: TutorialManager

func setup(tutorial_manager: TutorialManager) -> void:
	_tutorial_manager = tutorial_manager

func run_tutorial_part(tutorial_part_enum: TutorialPartEnum) -> void:
	_tutorial_manager.is_in_skippable_cinematic = true
	match tutorial_part_enum:
		TutorialPartEnum.DAY_0_0:
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.0)
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_0")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_1")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_2")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_3")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_4")

			Global.player.override_position_rotation(_tutorial_manager._day_0_sato_front_door_position.global_position, _tutorial_manager._day_0_sato_front_door_position.global_rotation)

			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_5")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_6")
			await _tutorial_manager._cinematic_camera.play_animation("day_0_intro_0_7")

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_0")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_1")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_1_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_2")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_3")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_4")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_5", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_1_5")
			await Global.voice_line_system.play_voice_line("day_0_intro_1_6", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_1_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_2_0")
			await Global.voice_line_system.play_voice_line("day_0_intro_2_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween_to_player: Tween = create_tween()
				tween_to_player.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 2.0)
				tween_to_player.set_parallel()
				tween_to_player.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 2.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(2.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(2.0)
		TutorialPartEnum.DAY_0_1:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_locker_room_preview_position.global_position, 2.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_locker_room_preview_position.global_rotation, 2.0)
			
			await Global.voice_line_system.play_voice_line("day_0_intro_3_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 1.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_0_2:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_break_room_preview_position.global_position, 2.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_break_room_preview_position.global_rotation, 2.0)

			await Global.voice_line_system.play_voice_line("day_0_intro_4_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_back_exit_preview_position.global_position, 2.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_back_exit_preview_position.global_rotation, 2.0)

			await Global.voice_line_system.play_voice_line("day_0_intro_4_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_4_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_4_0")

			await Global.voice_line_system.play_voice_line("day_0_intro_4_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_4_1")

			await Global.voice_line_system.play_voice_line("day_0_intro_4_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_4_5", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_4_6", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_4_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_4_8", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_4_2")

			await Global.voice_line_system.play_voice_line("day_0_intro_4_9", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_5_0")

			await Global.voice_line_system.play_voice_line("day_0_intro_5_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_5_1")

			await Global.voice_line_system.play_voice_line("day_0_intro_5_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_6_0")

			await Global.voice_line_system.play_voice_line("day_0_intro_6_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_6_1")

			await Global.voice_line_system.play_voice_line("day_0_intro_6_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_6_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_6_2")

			await Global.voice_line_system.play_voice_line("day_0_intro_6_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_6_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_7_0")

			await Global.voice_line_system.play_voice_line("day_0_intro_7_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_7_1")

			await Global.voice_line_system.play_voice_line("day_0_intro_7_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_7_2")

			await Global.voice_line_system.play_voice_line("day_0_intro_7_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_7_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_8_0")

			await Global.voice_line_system.play_voice_line("day_0_intro_8_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_8_1")

			await Global.voice_line_system.play_voice_line("day_0_intro_8_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			_tutorial_manager._cinematic_camera.disable_cinematic_camera(0.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
		TutorialPartEnum.DAY_0_3:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_9_0")
		
			await Global.voice_line_system.play_voice_line("day_0_intro_9_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_0_4:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_made_drink_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_made_drink_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_10_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_accept_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_accept_button_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_10_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 0.5)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 0.5)
			
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_0_5:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_machine_screen_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_machine_screen_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_11_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_made_drink_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_made_drink_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_11_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_remake_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_remake_button_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_11_5", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_6", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_8", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 0.5)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 0.5)
			
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_0_6:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_made_drink_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_made_drink_preview_position.global_rotation, 1.0)
			
			await Global.voice_line_system.play_voice_line("day_0_intro_11_repeat_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_repeat_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_remake_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_remake_button_preview_position.global_rotation, 1.0)
			
			await Global.voice_line_system.play_voice_line("day_0_intro_11_repeat_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_repeat_5", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_11_repeat_6", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 0.5)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 0.5)

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_0_7:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(false)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			
			await Global.voice_line_system.play_voice_line("day_0_intro_12_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_12_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_12_2", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(true)
		TutorialPartEnum.DAY_0_8:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
		
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_ingredients_bar_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_ingredients_bar_preview_position.global_rotation, 1.0)
		
			await Global.voice_line_system.play_voice_line("day_0_intro_13_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_13_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_13_4", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_13_0")
		
			await Global.voice_line_system.play_voice_line("day_0_intro_13_5", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_0_intro_13_1")
		
			await Global.voice_line_system.play_voice_line("day_0_intro_13_6", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_0_9:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			await _tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = _tutorial_manager._day_0_ingredients_bar_preview_position.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = _tutorial_manager._day_0_ingredients_bar_preview_position.global_rotation
			
			await Global.voice_line_system.play_voice_line("day_0_intro_14_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_0_intro_14_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_1_0:
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.0)
		
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_0")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_1")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_2")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_3")
		
			Global.player.visible = false
		
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_1_0")
		
			Global.player.visible = true

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_1_1")
		
			await Global.voice_line_system.play_voice_line("day_1_intro_0_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_1_2")
			await Global.voice_line_system.play_voice_line("day_1_intro_0_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_1_3")
			await Global.voice_line_system.play_voice_line("day_1_intro_0_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_0_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
		TutorialPartEnum.DAY_1_1:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(1.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(1.0)
		
			# Face the tablet.
			if true:
				var tween: Tween = create_tween()
				var direction_to_tippy_tablet: Vector3 = _tutorial_manager._cinematic_camera.camera_rig_node.global_position\
						.direction_to(_tutorial_manager._day_1_tippy_tablet_prop.global_position)\
						.rotated(Vector3.UP, deg_to_rad(90.0))
				# Flatten the roll on the direction
				direction_to_tippy_tablet.z = 0.0
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", direction_to_tippy_tablet, 1.0)
				await tween.finished
		
			# Pick up the tablet.
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._day_1_tippy_tablet_prop, "global_position", _tutorial_manager._day_1_tippy_tablet_camera_target_location.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._day_1_tippy_tablet_prop, "global_rotation", _tutorial_manager._day_1_tippy_tablet_camera_target_location.global_rotation, 1.0)
				await tween.finished
		
			await Global.voice_line_system.play_voice_line("day_1_intro_1_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_5", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_6", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_8", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_9", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_10", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_11", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_12", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_13", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_1_14", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
		
			# Hide the Tippy Tablet prop
			_tutorial_manager._day_1_tippy_tablet_prop.visible = false

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_2_0")
			await Global.voice_line_system.play_voice_line("day_1_intro_2_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_2_1")
			await Global.voice_line_system.play_voice_line("day_1_intro_2_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_2_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_2_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("day_1_intro_2_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_3_0")
			await Global.voice_line_system.play_voice_line("day_1_intro_3_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_intro_3_1")
			await Global.voice_line_system.play_voice_line("day_1_intro_3_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		_:
			printerr("run_tutorial_part(): Unknown TutorialPartEnum.")
	
	_tutorial_manager.is_in_skippable_cinematic = false
	finished_tutorial_part = true

func skip_tutorial_part(tutorial_part_enum: TutorialPartEnum) -> void:
	_tutorial_manager.is_in_skippable_cinematic = false
	await get_tree().process_frame
	
	Global.voice_line_system.safe_interrupt_all_voice_lines()
	
	await _tutorial_manager._cinematic_camera.play_animation("skip_cutscene_fade_to_black")
	
	match tutorial_part_enum:
		TutorialPartEnum.DAY_0_0:
			Global.player.override_position_rotation(_tutorial_manager._day_0_sato_front_door_position.global_position, _tutorial_manager._day_0_sato_front_door_position.global_rotation)
		TutorialPartEnum.DAY_0_1:
			pass
		TutorialPartEnum.DAY_0_2:
			pass
		TutorialPartEnum.DAY_0_3:
			pass
		TutorialPartEnum.DAY_0_4:
			pass
		TutorialPartEnum.DAY_0_5:
			pass
		TutorialPartEnum.DAY_0_6:
			pass
		TutorialPartEnum.DAY_0_7:
			pass
		TutorialPartEnum.DAY_0_8:
			pass
		TutorialPartEnum.DAY_0_9:
			pass
		TutorialPartEnum.DAY_1_0:
			pass
		TutorialPartEnum.DAY_1_1:
			# Hide the Tippy Tablet prop
			_tutorial_manager._day_1_tippy_tablet_prop.visible = false
			pass
		_:
			printerr("skip_tutorial_part(): Unknown TutorialPartEnum.")
	
	_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
	_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
	_tutorial_manager._cinematic_camera.play_animation("skip_cutscene_fade_to_view")
	_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
	await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
	
	
