class_name ShiftEndScreen
extends CanvasLayer

@export var background: ColorRect
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
@export var pencil_scribble: AudioStreamPlayer
@export var win_music: AudioStreamPlayer
@export var lose_music: AudioStreamPlayer
@export var animation_player: AnimationPlayer
@export var cafe_profits: RichTextLabel
@export var goal: RichTextLabel
@export var earnings: RichTextLabel
@export var new_ui_container: Control
@export var first_part_container: Control
@export var second_part_container: Control
@export var day_label: RichTextLabel
@export var cond_def: RichTextLabel
@export var cond_bonus: RichTextLabel
@export var bonus_item: TextureRect
@export var bonus_item_rarity_color_rect: ColorRect
@export var guaranteed_item: TextureRect
@export var guaranteed_item_rarity_color_rect: ColorRect
@export var rating_reward: TextureRect
@export var rating_locked: TextureRect
@export var star_bar: TextureProgressBar
@export var restart_button: TextureButton
@export var end_shift_button: TextureButton
@export var times_up: TextureRect
@export var tippy_times_up: TextureRect
@export var item_hover_tooltip: ItemHoverTooltip
@export var lock: TextureRect
@export var star_meter_gain_sound: AudioStreamPlayer

var reached_bonus_rating: bool = (
	Global.employee_rating >= Stats.current.item_bonus_rating_threshold
)


func _ready() -> void:
	restart_button.pressed.connect(func():Events.end_screen_finished.emit())
	#end_shift_button.pressed.connect(func():Events.end_screen_finished.emit())

	end_shift_button.pressed.connect(
		func():
		if Global.day == Global.final_day:
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.FINAL_COMIC_SCENE)
		else:
			Events.end_screen_finished.emit(),
	)

	end_shift_button.mouse_entered.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(end_shift_button, "offset_transform_scale", Vector2.ONE * 1.1, 0.1)
			t.tween_property(end_shift_button, "offset_transform_rotation", deg_to_rad(-1), 0.1),
	)
	end_shift_button.mouse_exited.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(end_shift_button, "offset_transform_scale", Vector2.ONE, 0.1)
			t.tween_property(end_shift_button, "offset_transform_rotation", deg_to_rad(1), 0.1),
	)

	Global.in_end_screen = true
	_play_screen()


func _exit_tree() -> void:
	Global.in_end_screen = false


func _play_screen() -> void:
	# Hide all the labels
	first_part_container.hide()
	second_part_container.hide()
	cafe_profits.hide()
	goal.hide()
	earnings.hide()

	# show time up screen
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	tippy_times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()
	tippy_times_up.hide()
	cond_bonus.text = "[right]get %s" % Stats.current.item_bonus_rating_threshold
	reached_bonus_rating = (
		Global.employee_rating >= Stats.current.item_bonus_rating_threshold
	)

	# calculate everything
	var daily_profit: float = Global.daily_cafe_money
	var min_profit_goal: float = Stats.current.daily_profit_goals_each_day[Global.day]
	var passed_profit_goal := daily_profit >= min_profit_goal
	if passed_profit_goal:
		animation_player.play("come_in_pass")
	else:
		animation_player.play("come_in_fail")
		lose_music.play()
	grant_day_rewards(passed_profit_goal)

	await animation_player.animation_finished

	var time: float = 1.2
	var time2: float = 1.5
	if passed_profit_goal:
		time = 0.3
		time2 = 4
		win_music.play()

	await get_tree().create_timer(0.7).timeout
	pencil_scribble.play()
	cafe_profits.show()
	win_shift_sound.pitch_scale = 1
	if not passed_profit_goal: win_shift_sound.play()

	await get_tree().create_timer(time).timeout
	goal.show()
	goal.text = "Goal . . . %s" % Global.float_to_price(min_profit_goal)
	win_shift_sound.pitch_scale = 1.2
	if not passed_profit_goal: win_shift_sound.play()

	await get_tree().create_timer(time).timeout
	earnings.show()
	earnings.text = "Earnings . . . %s" % Global.float_to_price(daily_profit)
	win_shift_sound.pitch_scale = 1.5
	if not passed_profit_goal: win_shift_sound.play()

	await get_tree().create_timer(time2).timeout

	if passed_profit_goal:
		var day: String = "Glorbsday"
		match Global.day:
			0: day = "Sunday"
			1: day = "Monday"
			2: day = "Tuesday"
			3: day = "Wednesday"
			4: day = "Thursday"
			5: day = "Friday"
		var g_item:Item = Global.get_item(Stats.current.daily_completion_item_unlocks.get(Global.day, [])[0])
		var b_item:Item = Global.get_item(Stats.current.daily_rating_item_unlocks.get(Global.day, [])[0])
		cond_def.text = "[center]clear day %s" % Global.day
		guaranteed_item.texture = g_item.icon
		guaranteed_item_rarity_color_rect.color = g_item.rarity_color
		guaranteed_item.mouse_entered.connect(
			func() -> void:
				item_hover_tooltip.item = g_item
		)
		guaranteed_item.mouse_exited.connect(
			func() -> void:
				item_hover_tooltip.item = null
		)
		bonus_item.texture = b_item.icon
		bonus_item_rarity_color_rect.color = b_item.rarity_color
		bonus_item.mouse_entered.connect(
			func() -> void:
				item_hover_tooltip.item = b_item
		)
		bonus_item.mouse_exited.connect(
			func() -> void:
				item_hover_tooltip.item = null
		)
		day_label.text = "[right]%s"%day
		animation_player.play("come_in_second_part")
		await animation_player.animation_finished
		var rating_tween:Tween = star_bar.create_tween()
		rating_tween.tween_property(star_bar,"value",Global.employee_rating/5 * 100,2)
		star_meter_gain_sound.play()
		await rating_tween.finished
		if reached_bonus_rating:
			bonus_item.self_modulate = Color.WHITE
			lock.hide()
			win_shift_sound.pitch_scale = 1.8
			win_shift_sound.play()
			rating_locked.texture = rating_reward.texture
		await get_tree().create_timer(0.4).timeout
		animation_player.play("endshift_button_arrive")
		create_tween().tween_property(win_music, "volume_db", -15, 1)
	else:
		lose_shift_sound.play()
		await get_tree().create_timer(0.7).timeout
		animation_player.play("restart_button_arrive")


func shake_screen(intensity:float):
	var shake_intensity: float = intensity
	var panel_original_position: Vector2 = new_ui_container.position
	var tween: Tween = new_ui_container.create_tween()
	var shake_offset_target: Vector2 = Vector2(randf_range(-shake_intensity, shake_intensity), 0)

	tween.tween_property(new_ui_container, "position", new_ui_container.position + shake_offset_target, 0.025)
	for i in range(10):
		shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)
		tween.chain().tween_property(
			new_ui_container,
			"position",
			new_ui_container.position + shake_offset_target,
			0.025,
		)

	tween.tween_property(new_ui_container, "position", panel_original_position, 0.1)


func grant_day_rewards(passed_day: bool) -> void:
	var current_day: int = Global.day

	#Tutorial doesn't unlock
	if current_day <= 0:
		return

	if passed_day:
		SaveDataManager.save_data.latest_unlocked_day = maxi(
			SaveDataManager.save_data.latest_unlocked_day,
			current_day + 1
		)

		var bonus_already_received: bool = (
			SaveDataManager.save_data.days_bonus_objective_completed.get(current_day, false)
		)

		if reached_bonus_rating and not bonus_already_received:
			SaveDataManager.save_data.days_bonus_objective_completed[current_day] = true

	Global.load_unlocked_items_from_save()
	SaveDataManager.save_game_to_file()
