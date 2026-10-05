class_name TutorialManager
extends Node

@warning_ignore_start("unused_private_class_variable")

@export var _player_ui_sub_viewport_container: PlayerUiSubViewportContainer
@export var _cinematic_camera: CinematicCamera

@export var _tippy_callouts_manager: TippyCalloutsManager
@export var _open_closed_sign: OpenClosedSign
@export var _day_0_sato_front_door_position: Node3D
@export var _day_0_employee_area_detector: PlayerDetectionArea
@export var _day_0_locker_room_preview_position: Node3D
@export var _day_0_break_room_area_detector: PlayerDetectionArea
@export var _day_0_break_room_preview_position: Node3D
@export var _day_0_back_exit_preview_position: Node3D
@export var _day_0_machine_screen_preview_position: Node3D
@export var _day_0_made_drink_preview_position: Node3D
@export var _day_0_accept_button_preview_position: Node3D
@export var _day_0_remake_button_preview_position: Node3D
@export var _day_0_ingredients_bar_preview_position: Node3D
@export var _day_1_sato_start_shift_sign_position: Node3D
@export var _day_1_machine_front_preview_position: Node3D
@export var _day_1_sato_at_machine_position: Node3D
@export var _day_1_tippy_tablet_area_detector: PlayerDetectionArea
@export var _day_1_tippy_tablet_prop: Node3D
@export var _day_1_tippy_tablet_camera_target_location: Node3D

var is_in_skippable_cinematic: bool = false
var skip_part_requested: bool = false

func _init() -> void:
	Global.tutorial_manager = self

func start_day() -> void:
	if Global.playing_tutorial:
		# Disable Tippy callouts
		_tippy_callouts_manager.enable_tippy_callouts = false

		# Hide the Tippy Tablet prop
		_day_1_tippy_tablet_prop.visible = false

		if Global.day == 1:
			# Enable the open sign
			_open_closed_sign.set_enabled(true)

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_0)

			# Repeat the lines until shift started.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_2_repeat_0",
				]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				var condition_callable: Callable = (
					func() -> bool:
						return Global.shift_started
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_1)

			# Repeat the lines until shift started.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_5_repeat_0",
					]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				Global.tutorial_machine_used = false
				var condition_callable: Callable = (
					func() -> bool:
						return Global.tutorial_machine_used
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_6", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_7", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			# First customer, accept order
			Global.main_scene.tutorial_machine.force_next_drink_perfect()
			Global.main_scene.tutorial_machine.set_order_action_buttons_available("accept")
			Global.main_scene.spawn_machine_customer()

			await Events.customer_started_order

			await Global.main_scene.tutorial_machine.drink_prepared

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_2)

			# Repeat the lines until accept button is pressed.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_10_repeat_0",
				]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				Global.tutorial_drink_correct_accepted = false
				var condition_callable: Callable = (
					func() -> bool:
						return Global.tutorial_drink_correct_accepted
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_3)

			# Second customer, an incorrect order
			Global.main_scene.tutorial_machine.force_next_drink_incorrect()
			Global.main_scene.tutorial_machine.set_order_action_buttons_available("accept_or_remake")
			Global.main_scene.spawn_machine_customer()

			await Events.customer_started_order

			await Global.main_scene.tutorial_machine.drink_prepared

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_4)

			# Repeat the lines until accept or remake button is pressed.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_25_a_3_repeat_0",
				]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				Global.tutorial_drink_incorrect_accepted = false
				Global.tutorial_remake_button_pressed = false
				var condition_callable: Callable = (
					func() -> bool:
						return Global.tutorial_drink_incorrect_accepted or Global.tutorial_remake_button_pressed
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			while true:
				if Global.tutorial_drink_incorrect_accepted:
					# Keep making the incorrect drink until it's remade.
					while true:
						# Refill the ingredients so it never runs out.
						Global.main_scene.tutorial_machine.ingredients = Stats.current.machine_starting_ingredients

						await Global.voice_line_system.play_voice_line("voice_line_day_1_training_25_a_0", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
						await Global.voice_line_system.play_voice_line("voice_line_day_1_training_25_a_1", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

						# Another incorrect order
						Global.main_scene.tutorial_machine.force_next_drink_incorrect()
						Global.main_scene.tutorial_machine.set_order_action_buttons_available("accept_or_remake")
						Global.main_scene.spawn_machine_customer()

						await Events.customer_started_order
						await Global.main_scene.tutorial_machine.drink_prepared

						is_in_skippable_cinematic = true

						await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_4_A)

						# Repeat the lines until accept or remake button is pressed.
						if true:
							var repeat_lines: Array[String] = [
								"voice_line_day_1_training_25_a_3_repeat_0",
								]
							var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
								VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
								]
							Global.tutorial_drink_incorrect_accepted = false
							Global.tutorial_remake_button_pressed = false
							var condition_callable: Callable = (
								func() -> bool:
									return Global.tutorial_drink_incorrect_accepted or Global.tutorial_remake_button_pressed
							)

							await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

						if Global.tutorial_remake_button_pressed:
							break

				await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_5)

				# Repeat the lines until drink is remade, or accept is pressed.
				if true:
					var repeat_lines: Array[String] = [
						"voice_line_day_1_training_28_repeat_0",
						"voice_line_day_1_training_28_repeat_1",
					]
					var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
						VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
						VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
					Global.tutorial_drink_incorrect_accepted = false
					Global.tutorial_drink_remake_ingredients_done = false
					var condition_callable: Callable = (
						func() -> bool:
							return Global.tutorial_drink_incorrect_accepted or Global.tutorial_drink_remake_ingredients_done
					)
					await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

				if Global.tutorial_drink_remake_ingredients_done:
					break

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_6)

			# Repeat the lines until drink is dragged over to be served.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_29_repeat_0",
				]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				Global.tutorial_drink_remade_served = false
				var condition_callable: Callable = (
					func() -> bool:
						return Global.tutorial_drink_remade_served
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_30", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

			# Machine runs out of ingredients.
			Global.main_scene.tutorial_machine.ingredients = 0
			Global.main_scene.tutorial_machine.no_ingredients_sound.play()
			Global.main_scene.tutorial_machine.set_order_action_buttons_available("refill")

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_7)

			# Repeat the lines until ingredient bag is picked up.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_33_repeat_0",
					]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				Global.tutorial_ingredients_bag_got = false
				var condition_callable: Callable = (
					func() -> bool:
						return Global.tutorial_ingredients_bag_got
				)

				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await get_tree().create_timer(1.0).timeout

			await _run_skippable_tutorial_part(SkippableTutorialPart.TutorialPartEnum.DAY_1_8)

			# Repeat the lines until ingredients are filled to enough.
			if true:
				var repeat_lines: Array[String] = [
					"voice_line_day_1_training_35_repeat_0",
					"voice_line_day_1_training_35_repeat_1",
					]
				var repeat_lines_location: Array[VoiceLineSystem.VoiceLineLocationEnum] = [
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA,
					]
				var condition_callable: Callable = (
					func() -> bool:
						return Global.main_scene.tutorial_machine.ingredients >= 10
				)
				await _repeat_line_until_condition_met(repeat_lines, repeat_lines_location, condition_callable)

			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_36", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_37", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)
			await Global.voice_line_system.play_voice_line("voice_line_day_1_training_38", VoiceLineSystem.VoiceLineLocationEnum.AT_CINEMATIC_CAMERA, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL)

		elif Global.day == 2:
			pass
		elif Global.day == 3:
			pass
		elif Global.day == 4:
			pass
		elif Global.day == 5:
			pass

		# Re-enable Tippy callouts
		_tippy_callouts_manager.enable_tippy_callouts = true

		# Mark the day's tutorial as played, if not marked yet
		if Global.day > SaveDataManager.save_data.latest_tutorial_completed_day:
			SaveDataManager.save_data.latest_tutorial_completed_day = Global.day
			SaveDataManager.save_game_to_file()

		# Reset the scene for a fresh load
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)

func _repeat_line_until_condition_met(voice_line_ids: Array[String], voice_line_locations: Array[VoiceLineSystem.VoiceLineLocationEnum], condition_callable: Callable) -> void:
	const REPEAT_INSTRUCTION_TIMER_DURATION: float = 10.0

	var repeat_instruction_timer: Timer = Timer.new()
	repeat_instruction_timer.wait_time = REPEAT_INSTRUCTION_TIMER_DURATION
	repeat_instruction_timer.autostart = false
	repeat_instruction_timer.one_shot = true
	add_child(repeat_instruction_timer)
	repeat_instruction_timer.start()

	while not condition_callable.call():
		if repeat_instruction_timer.time_left == 0.0:
			var voice_lines_index: int = 0
			while not condition_callable.call():
				var out_token: Array[VoiceLinePlaybackToken]
				var voice_line_id: String = voice_line_ids[voice_lines_index]
				var voice_line_location: VoiceLineSystem.VoiceLineLocationEnum = voice_line_locations[voice_lines_index]
				Global.voice_line_system.play_voice_line(voice_line_id, voice_line_location, VoiceLineSystem.VoiceLinePriorityEnum.TUTORIAL, out_token)
				var playback_token: VoiceLinePlaybackToken = out_token[0]
				while not condition_callable.call():
					if playback_token.is_finished_playing:
						break
					else:
						await get_tree().process_frame

				voice_lines_index += 1
				if voice_lines_index >= voice_line_ids.size():
					voice_lines_index = 0
					break

			repeat_instruction_timer.start()
		else:
			await get_tree().process_frame

	repeat_instruction_timer.stop()
	repeat_instruction_timer.queue_free()

func _run_skippable_tutorial_part(tutorial_part_enum: SkippableTutorialPart.TutorialPartEnum) -> void:
	var skippable_tutorial_part: SkippableTutorialPart = SkippableTutorialPart.new()
	add_child(skippable_tutorial_part)
	skippable_tutorial_part.setup(self)
	skippable_tutorial_part.run_tutorial_part(tutorial_part_enum)
	while !skippable_tutorial_part.finished_tutorial_part:
		if skip_part_requested:
			skip_part_requested = false
			skippable_tutorial_part.queue_free()
			skippable_tutorial_part = SkippableTutorialPart.new()
			add_child(skippable_tutorial_part)
			skippable_tutorial_part.setup(self)
			await skippable_tutorial_part.skip_tutorial_part(tutorial_part_enum)
			return
		await get_tree().process_frame
	skippable_tutorial_part.queue_free()
