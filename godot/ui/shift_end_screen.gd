extends CanvasLayer

@export var background: ColorRect
@export var times_up: RichTextLabel
@export var outcome: RichTextLabel
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
@export var _money_title_label: RichTextLabel
@export var _min_profit_goal_label: RichTextLabel
@export var _max_profit_goal_label: RichTextLabel
@export var _profit_made_label: RichTextLabel
@export var _rating_title_label: RichTextLabel
@export var _rating_label: RichTextLabel
@export var _tips_per_star_label: RichTextLabel
@export var _tip_jar_desc_label: RichTextLabel
@export var _tips_today_label: RichTextLabel
@export var _bank_total_label: RichTextLabel
@export var bank_gain_sound: AudioStreamPlayer
@export var pencil_scribble: AudioStreamPlayer
@export var _profit_judgement_container: Control
@export var profit_judgement_textures: Array[Texture]
@export var profit_judgement_texture_rect: TextureRect
@export var button: Button
@export var stars_sound: AudioStreamPlayer
@export var _free_item_selector_screen_packed_scene: PackedScene
@export var _free_item_selector_screen_container: Control

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
	_max_profit_goal_label.visible = false
	_profit_made_label.visible = false

	_profit_judgement_container.visible = false

	_rating_title_label.visible = false
	_rating_label.visible = false
	_tips_per_star_label.visible = false
	_tip_jar_desc_label.visible = false
	_tips_today_label.visible = false
	_bank_total_label.visible = false
	
	# show time up screen
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()

	# calculate everything
	var daily_profit := Global.daily_cafe_money
	var min_profit_goal: float = Stats.current.daily_profit_goals_each_day[Global.day]
	var max_profit_goal: float = Stats.current.perfect_profit_goals_each_day[Global.day]
	var passed_profit_goal := daily_profit >= min_profit_goal

	_min_profit_goal_label.text = "required goal: %s" % Global.float_to_price(min_profit_goal)
	_max_profit_goal_label.text = "perfect goal: %s" % Global.float_to_price(max_profit_goal)
	_profit_made_label.text = "made today: %s/%s" % [
		Global.float_to_price(daily_profit),
		Global.float_to_price(min_profit_goal),
	]
	
	_rating_label.text = "⭐ %s / %s" % [Global.employee_rating, Stats.current.employee_rating_max]
	var tip_per_star: float = Stats.current.tip_per_star_rating
	var show_tip_jar_desc: bool = false
	for item in Global.owned_items:
		if item.item_id == "tip_jar":
			_tip_jar_desc_label.visible = true
			var tip_multiplier: float = 1.0
			if item.item_level == 1:
				tip_multiplier = 1.5
			elif item.item_level == 2:
				tip_multiplier = 3.0
			tip_per_star *= tip_multiplier
			_tip_jar_desc_label.text = "x%s from Tip Jar!" % tip_multiplier
	_tips_per_star_label.text = "$%s tip per full star" % tip_per_star
	var tips: float = tip_per_star * (floori(Global.employee_rating))
	_tips_today_label.text = "= [color=gold]%s[/color] tips" % Global.float_to_price(tips)
	
	pencil_scribble.play()

	_money_title_label.visible = true
	await get_tree().create_timer(0.5).timeout
	_min_profit_goal_label.visible = true
	await get_tree().create_timer(0.1).timeout
	_max_profit_goal_label.visible = true
	await get_tree().create_timer(0.2).timeout
	_profit_made_label.visible = true
	
	var profit_made_tween := create_tween()
	if passed_profit_goal:
		profit_made_tween.tween_property(_profit_made_label, "modulate", Color.WHITE, 1).from(Color.GREEN)
	else:
		profit_made_tween.tween_property(_profit_made_label, "modulate", Color.RED, 1)

	await get_tree().create_timer(1).timeout

	var profit_judgement_texture_index: int = 0
	if passed_profit_goal:
		var profit_judgement_index_float: float = remap(daily_profit, min_profit_goal, max_profit_goal, 0.0, 11.0)
		if daily_profit <= max_profit_goal: 
			profit_judgement_texture_index = floori(profit_judgement_index_float)
		else:
			profit_judgement_texture_index = profit_judgement_textures.size() - 1
	if profit_judgement_texture_index >= 0 and profit_judgement_texture_index < profit_judgement_textures.size():
		profit_judgement_texture_rect.texture = profit_judgement_textures[profit_judgement_texture_index]
	_profit_judgement_container.visible = true
	stars_sound.play()

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
	
	if passed_profit_goal:
		await get_tree().create_timer(0.1).timeout
		_tips_per_star_label.visible = true
		if show_tip_jar_desc:
			_tip_jar_desc_label.visible = true
		await get_tree().create_timer(0.2).timeout
		_tips_today_label.visible = true
		await get_tree().create_timer(0.5).timeout
		
		_bank_total_label.visible = true
		value_to_show_on_bank_total = Global.player_tips_bank
		Global.player_tips_bank += tips
		await get_tree().create_timer(0.5).timeout
		if Global.player_tips_bank > value_to_show_on_bank_total:
			bank_gain_sound.play()
			var t := create_tween().tween_property(
					self,
					"value_to_show_on_bank_total",
					Global.player_tips_bank,
					0.75,
					)
			await t.finished

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
