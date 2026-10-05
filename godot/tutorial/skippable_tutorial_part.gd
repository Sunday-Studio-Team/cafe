class_name SkippableTutorialPart
extends Node

enum TutorialPartEnum {
	DAY_1_0,
	DAY_1_1,
	DAY_1_2,
	DAY_1_3,
	DAY_1_4,
	DAY_1_4_A,
	DAY_1_5,
	DAY_1_6,
	DAY_1_7,
	DAY_1_8,
	DAY_2_0,
}

var finished_tutorial_part: bool = false

var _tutorial_manager: TutorialManager

func setup(tutorial_manager: TutorialManager) -> void:
	_tutorial_manager = tutorial_manager

func run_tutorial_part(tutorial_part_enum: TutorialPartEnum) -> void:
	_tutorial_manager.is_in_skippable_cinematic = true
	match tutorial_part_enum:
		TutorialPartEnum.DAY_1_0:
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.0)
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_0")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_1")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_2")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_3")

			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_4")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_0", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_1", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_2", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_3", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_4", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_5", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_6", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_7", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_8", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_intro_9", VoiceLineSystem.VoiceLineLocationEnum.AROUND_CAFE, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await _tutorial_manager._cinematic_camera.play_animation("day_1_intro_0_5")

			await _tutorial_manager._cinematic_camera.play_animation("day_1_training_0_0")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_0", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_1", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_training_2_0")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_2", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			Global.player.override_position_rotation(_tutorial_manager._day_1_sato_start_shift_sign_position.global_position, _tutorial_manager._day_1_sato_start_shift_sign_position.global_rotation)
			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", Global.player.camera.camera_effects.global_position, 2.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", Global.player.camera.camera_effects.global_rotation, 2.0)
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(2.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(2.0)
		TutorialPartEnum.DAY_1_1:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_3", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await get_tree().create_timer(1.0).timeout

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_1_machine_front_preview_position.global_position, 2.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_1_machine_front_preview_position.global_rotation, 2.0)
				await tween.finished

			await get_tree().create_timer(1.0).timeout

			_tutorial_manager._cinematic_camera.play_animation("day_1_training_3_0")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_4", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await _tutorial_manager._cinematic_camera.play_animation("day_1_training_3_1")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_5", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			Global.player.override_position_rotation(_tutorial_manager._day_1_sato_at_machine_position.global_position, _tutorial_manager._day_1_sato_at_machine_position.global_rotation)
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_2:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_machine_screen_preview_position.global_position, 0.5)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_machine_screen_preview_position.global_rotation, 0.5)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_8", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_9", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_accept_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_accept_button_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_10", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_3:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.0, false)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_11", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(Global.player.tippy_tablet_3d, "global_position", Global.player.tippy_tablet_up_front_position_rotation.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(Global.player.tippy_tablet_3d, "global_rotation", Global.player.tippy_tablet_up_front_position_rotation.global_rotation, 1.0)
				await tween.finished

			await get_tree().create_timer(1.0).timeout
			Global.player.tippy_tablet_3d.money_and_goal_tutorial_indicator.visible = true
			await get_tree().create_timer(1.0).timeout

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_12", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_13", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			Global.player.tippy_tablet_3d.money_and_goal_tutorial_indicator.visible = false
			Global.player.tippy_tablet_3d.clock_tutorial_indicator.visible = true
			await get_tree().create_timer(1.0).timeout

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_14", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_15", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			Global.player.tippy_tablet_3d.clock_tutorial_indicator.visible = false
			Global.player.tippy_tablet_3d.rating_tutorial_indicator.visible = true
			await get_tree().create_timer(1.0).timeout

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_16", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_17", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_18", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_19", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_20", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_21", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			Global.player.tippy_tablet_3d.rating_tutorial_indicator.visible = false

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(Global.player.tippy_tablet_3d, "global_position", Global.player.tippy_tablet_normal_position_rotation.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(Global.player.tippy_tablet_3d, "global_rotation", Global.player.tippy_tablet_normal_position_rotation.global_rotation, 1.0)
				await tween.finished

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_22", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_4:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_made_drink_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_made_drink_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_23", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_24", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_remake_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_remake_button_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_25", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_4_A:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_made_drink_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_made_drink_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_25_a_2", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_remake_button_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_remake_button_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_25_a_3", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_5:
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(false)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_26", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_27", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_28", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await _tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(true)
		TutorialPartEnum.DAY_1_6:
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(false)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_29", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await _tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(true)
		TutorialPartEnum.DAY_1_7:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_ingredients_bar_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_ingredients_bar_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_31", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_32", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			await _tutorial_manager._cinematic_camera.play_animation("day_1_training_32_0")
			await _tutorial_manager._cinematic_camera.play_animation("day_1_training_32_1")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_33", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_1_8:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.5)

			if true:
				var tween: Tween = create_tween()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_position", _tutorial_manager._day_0_machine_screen_preview_position.global_position, 1.0)
				tween.set_parallel()
				tween.tween_property(_tutorial_manager._cinematic_camera.camera_rig_node, "global_rotation", _tutorial_manager._day_0_machine_screen_preview_position.global_rotation, 1.0)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_34", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.play_animation("day_1_training_34_0")

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_35", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(1.0)
			await _tutorial_manager._cinematic_camera.disable_cinematic_camera(1.0)
		TutorialPartEnum.DAY_2_0:
			_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
			_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
			_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.0, false)
			_tutorial_manager._cinematic_camera.cinematic_bars.show_bars(0.0)

			await _tutorial_manager._cinematic_camera.play_animation("day_2_intro_0_0")

			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_0", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_1", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_2", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_3", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_4", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_5", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_6", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_7", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_8", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_9", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_10", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_11", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_12", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_13", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_14", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_15", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_16", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_17", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_2_intro_18", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

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
		TutorialPartEnum.DAY_1_0:
			Global.player.override_position_rotation(_tutorial_manager._day_1_sato_start_shift_sign_position.global_position, _tutorial_manager._day_1_sato_start_shift_sign_position.global_rotation)
		TutorialPartEnum.DAY_1_1:
			Global.player.override_position_rotation(_tutorial_manager._day_1_sato_at_machine_position.global_position, _tutorial_manager._day_1_sato_at_machine_position.global_rotation)
		TutorialPartEnum.DAY_1_2:
			pass
		TutorialPartEnum.DAY_1_3:
			Global.player.tippy_tablet_3d.global_position =  Global.player.tippy_tablet_normal_position_rotation.global_position
			Global.player.tippy_tablet_3d.global_rotation =  Global.player.tippy_tablet_normal_position_rotation.global_rotation
			Global.player.tippy_tablet_3d.hide_all_indicators()
		TutorialPartEnum.DAY_1_4:
			pass
		TutorialPartEnum.DAY_1_5:
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(true)
		TutorialPartEnum.DAY_1_6:
			_tutorial_manager._player_ui_sub_viewport_container.set_allow_input(true)
		TutorialPartEnum.DAY_1_7:
			pass
		TutorialPartEnum.DAY_1_8:
			pass
		_:
			printerr("skip_tutorial_part(): Unknown TutorialPartEnum.")

	_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
	_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
	_tutorial_manager._cinematic_camera.play_animation("skip_cutscene_fade_to_view")
	_tutorial_manager._cinematic_camera.cinematic_bars.hide_bars(0.5)
	await _tutorial_manager._cinematic_camera.disable_cinematic_camera(0.5)
