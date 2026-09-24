extends CanvasLayer

@export var background: ColorRect
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
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

var reached_bonus_rating: bool = (
	Global.employee_rating >= Stats.current.item_bonus_rating_threshold
)


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

	button.pressed.connect(
		func():
			Events.end_screen_finished.emit(),
	)

	_on_time_up()


func _process(_delta: float) -> void:

	if visible:
		Global.in_end_screen = true
	else:
		Global.in_end_screen = false


func _on_time_up() -> void:
	# Hide all the labels
	
	cafe_profits.hide()
	goal.hide()
	earnings.hide()
	# show time up screen
	show()
	background.show()
	get_tree().paused = true
	#times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	#times_up.hide()
	reached_bonus_rating = (
		Global.employee_rating >= Stats.current.item_bonus_rating_threshold
	)

	# calculate everything
	var daily_profit := 67 #Global.daily_cafe_money
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
			button.text = "end run"
		else:
			button.text = "continue"
		win_shift_sound.play()
	else:
		button.text = "new run"
		lose_shift_sound.play()

	await get_tree().create_timer(1.0).timeout

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
		
		var bonus_already_received: bool = (
			SaveDataManager.save_data.days_bonus_objective_completed.get(current_day, false)
		)
	
		if reached_bonus_rating and not bonus_already_received:
			SaveDataManager.save_data.days_bonus_objective_completed[current_day] = true
	
	Global.load_unlocked_items_from_save()
	SaveDataManager.save_game_to_file()
