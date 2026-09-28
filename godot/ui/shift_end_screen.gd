extends CanvasLayer

@export var background: ColorRect
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
@export var bank_gain_sound: AudioStreamPlayer
@export var pencil_scribble: AudioStreamPlayer
@export var stars_sound: AudioStreamPlayer

@export_group("New UI")
@export var animation_player: AnimationPlayer
@export var cafe_profits: RichTextLabel
@export var goal: RichTextLabel
@export var earnings: RichTextLabel
@export var new_ui_container: Control
@export var first_part_container: Control
@export var second_part_container: Control
@export var day_label: RichTextLabel
@export var cond_def: RichTextLabel
@export var bonus_item: TextureRect
@export var guaranteed_item: TextureRect
@export var rating_reward: TextureRect
@export var rating_locked: TextureRect
@export var star_bar: TextureProgressBar
@export var restart_button: TextureButton
@export var end_shift_button: TextureButton

@export var lock: TextureRect

var reached_bonus_rating: bool = (
	Global.employee_rating >= 4.5#Stats.current.item_bonus_rating_threshold
)


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

	restart_button.pressed.connect(func():Events.end_screen_finished.emit(),)
	end_shift_button.pressed.connect(func():Events.end_screen_finished.emit(),)


func _process(_delta: float) -> void:

	if visible:
		Global.in_end_screen = true
	else:
		Global.in_end_screen = false


func _on_time_up() -> void:
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
	#times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	#times_up.hide()#
	reached_bonus_rating = (
		Global.employee_rating >= 4.5#Stats.current.item_bonus_rating_threshold
	)

	# calculate everything
	
	var daily_profit := Global.daily_cafe_money
	var min_profit_goal: float = Stats.current.daily_profit_goals_each_day[Global.day]
	var passed_profit_goal := daily_profit >= min_profit_goal
	animation_player.play("come_in_pass" if passed_profit_goal else "come_in_fail")
	
	grant_day_rewards(passed_profit_goal)
	await animation_player.animation_finished
	
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

	await get_tree().create_timer(1.5).timeout
	if passed_profit_goal:
		var day:String = "Glorbsday"
		match Global.day:
			0: day = "Sunday"
			1: day = "Monday"
			2: day = "Tuesday"
			3: day = "Wednesday"
			4: day = "Thursday"
			5: day = "Friday"
		var g_item:Item = Global.get_item(Stats.current.daily_completion_item_unlocks.get(Global.day, [])[0])
		var b_item:Item = Global.get_item(Stats.current.daily_rating_item_unlocks.get(Global.day, [])[0])
		guaranteed_item.texture = g_item.icon
		bonus_item.texture = b_item.icon
		day_label.text = "[right]%s"%day
		animation_player.play("come_in_second_part")
		await animation_player.animation_finished
		var rating_tween:Tween = star_bar.create_tween()
		rating_tween.tween_property(star_bar,"value",Global.employee_rating/5 * 100,2)
		await rating_tween.finished
		if reached_bonus_rating:
			bonus_item.self_modulate = Color.WHITE
			lock.hide()
			win_shift_sound.pitch_scale = 1.8
			win_shift_sound.play()
			rating_locked.texture = rating_reward.texture
		await get_tree().create_timer(0.4).timeout
		animation_player.play("endshift_button_arrive")
	else:
		lose_shift_sound.play()
		await get_tree().create_timer(0.7).timeout
		animation_player.play("restart_button_arrive")

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
