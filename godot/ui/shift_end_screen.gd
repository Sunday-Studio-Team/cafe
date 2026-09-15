extends CanvasLayer

@export var background: ColorRect
@export var _day_label: RichTextLabel
@export var times_up: RichTextLabel
@export var outcome: RichTextLabel
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
@export var _money_title_label: RichTextLabel
@export var _min_profit_goal_label: RichTextLabel
@export var _profit_made_label: RichTextLabel
@export var _rating_title_label: RichTextLabel
@export var _rating_label: RichTextLabel
@export var _tips_per_star_label: RichTextLabel
@export var _tip_jar_desc_label: RichTextLabel
@export var _tips_today_label: RichTextLabel
@export var _bank_total_label: RichTextLabel
@export var bank_gain_sound: AudioStreamPlayer
@export var pencil_scribble: AudioStreamPlayer
@export var button: Button
@export var stars_sound: AudioStreamPlayer

@export_group("New UI")
@export var animation_player: AnimationPlayer
@export var cafe_profits: RichTextLabel
@export var goal: RichTextLabel
@export var earnings: RichTextLabel
@export var new_ui_container: Control


var value_to_show_on_bank_total: float


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

	button.pressed.connect(
		func():
			Events.end_screen_finished.emit(),
	)

	button.mouse_entered.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(button, "offset_transform_scale", Vector2.ONE * 1.1, 0.1)
			t.tween_property(button, "offset_transform_rotation", deg_to_rad(-1), 0.1),
	)
	button.mouse_exited.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(button, "offset_transform_scale", Vector2.ONE, 0.1)
			t.tween_property(button, "offset_transform_rotation", deg_to_rad(1), 0.1),
	)
	_on_time_up()


func _process(_delta: float) -> void:
	_bank_total_label.text = "🏦 Your Bank: [color=gold]%s[/color]" % Global.float_to_price(
		value_to_show_on_bank_total
	)

	if visible:
		Global.in_end_screen = true
	else:
		Global.in_end_screen = false


func _on_time_up() -> void:
	# Hide all the labels
	_money_title_label.visible = false
	_min_profit_goal_label.visible = false
	_profit_made_label.visible = false
	_day_label.visible = false


	_rating_title_label.visible = false
	_rating_label.visible = false
	_tips_per_star_label.visible = false
	_tip_jar_desc_label.visible = false
	_tips_today_label.visible = false
	_bank_total_label.visible = false
	
	cafe_profits.hide()
	goal.hide()
	earnings.hide()
	# show time up screen
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()
	

	# calculate everything
	var daily_profit := 7 #Global.daily_cafe_money
	var min_profit_goal: float = 30 #Stats.current.daily_profit_goals_each_day[Global.day]
	var passed_profit_goal := daily_profit >= min_profit_goal
	animation_player.play("come_in_pass" if passed_profit_goal else "come_in_fail")
	
	grant_day_rewards(passed_profit_goal)
	await animation_player.animation_finished

	#_day_label.text = Global.day_to_string(Global.day)
	#_day_label.text = "Day %d" % (Global.day)
	#_min_profit_goal_label.text = "required goal: %s" % Global.float_to_price(min_profit_goal)
	#_profit_made_label.text = "made today: %s/%s" % [
		#Global.float_to_price(daily_profit),
		#Global.float_to_price(min_profit_goal),
	#]
	
	_rating_label.text = "⭐ %s / %s" % [Global.employee_rating, Stats.current.employee_rating_max]
	
	pencil_scribble.play()
	
	cafe_profits.show()
	win_shift_sound.pitch_scale = 1
	win_shift_sound.play()
	await get_tree().create_timer(1.2).timeout
	goal.show()
	goal.text = "Goal . . . %s" % Global.float_to_price(min_profit_goal)
	win_shift_sound.pitch_scale = 1.2
	win_shift_sound.play()
	await get_tree().create_timer(1.2).timeout
	earnings.show()
	earnings.text = "Earnings . . . %s" % Global.float_to_price(daily_profit)
	win_shift_sound.pitch_scale = 1.5
	win_shift_sound.play()

	#_money_title_label.visible = true
	#await get_tree().create_timer(0.5).timeout
	#_min_profit_goal_label.visible = true
	#await get_tree().create_timer(0.2).timeout
	#_profit_made_label.visible = true
	
	#var profit_made_tween := create_tween()
	#if passed_profit_goal:
		#profit_made_tween.tween_property(_profit_made_label, "modulate", Color.WHITE, 1).from(Color.GREEN)
	#else:
		#profit_made_tween.tween_property(_profit_made_label, "modulate", Color.RED, 1)

	await get_tree().create_timer(1.5).timeout

	# show outcome text and button
	if (
			Global.daily_cafe_money >= Stats.current.daily_profit_goals_each_day[Global.day]
	):
		if Global.day == Global.final_day:
			outcome.text = "[b][color=green]YOU WIN"
			button.text = "end run"
		else:
			outcome.text = "[b][color=green]SHIFT CLEARED"
			button.text = "continue"
		win_shift_sound.play()
	else:
		outcome.text = "[b][color=red]FIRED"
		button.text = "new run"
		lose_shift_sound.play()

	outcome.show()

	await get_tree().create_timer(1.0).timeout

	_rating_title_label.visible = true
	await get_tree().create_timer(0.5).timeout
	_rating_label.visible = true

	await get_tree().create_timer(0.5).timeout

	# If player has a free item slot,
	# and if 5 star customer satisfaction, give free selection of 1 of 3 random items
	# NOTE: disabled for now
	#var has_free_item_slots: bool = Global.owned_items.size() <= Global.item_slots_amount
	#var made_enough_money: bool = Global.daily_profit >= Stats.current.daily_profit_goal
	#var five_star_rating: int = 10
	#var got_five_stars: bool = Global.employee_rating >= five_star_rating
	#if has_free_item_slots and made_enough_money and got_five_stars:
	#var free_item_selector_screen: FreeItemSelectorScreen = _free_item_selector_screen_packed_scene.instantiate()
	#if free_item_selector_screen == null:
	#printerr("FreeItemSelectorScreen is null.")
	#return
	#_free_item_selector_screen_container.add_child(free_item_selector_screen)
	#await free_item_selector_screen.finished_selection
	#free_item_selector_screen.queue_free()
	button.show()
	await get_tree().create_timer(2).timeout
	var button_shine_tween := create_tween().set_loops()
	button_shine_tween.tween_property(button, "modulate", Color.from_hsv(0.0, 0.0, 1.374, 1.0), 1)
	button_shine_tween.tween_property(button, "modulate", Color.WHITE, 1)
	button_shine_tween.tween_interval(2)

func shake_screen(intensity:float):
	var shake_intensity = intensity
	var panel_original_position: Vector2 = new_ui_container.position
	var tween = new_ui_container.create_tween()
	var shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)

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
		
		var reached_bonus_rating: bool = (
			Global.employee_rating >= Stats.current.item_bonus_rating_threshold
		)
	
		var bonus_already_received: bool = (
			SaveDataManager.save_data.days_bonus_objective_completed.get(current_day, false)
		)
	
		if reached_bonus_rating and not bonus_already_received:
			SaveDataManager.save_data.days_bonus_objective_completed[current_day] = true
	
	Global.load_unlocked_items_from_save()
	SaveDataManager.save_game_to_file()
