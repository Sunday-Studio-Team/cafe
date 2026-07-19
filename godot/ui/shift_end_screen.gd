extends CanvasLayer

@export var background: ColorRect
@export var times_up: RichTextLabel
@export var outcome: RichTextLabel
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer
@export var money_calculation_screen: Container
@export var profit: RichTextLabel
@export var boss_cut: RichTextLabel
@export var banked_today: RichTextLabel
@export var bank_total: RichTextLabel
@export var bank_gain_sound: AudioStreamPlayer
@export var pencil_scribble: AudioStreamPlayer
@export var rating_stars_hbox: HBoxContainer
@export var rating_breakdown: Control
@export var button: Button
@export var stars_sound: AudioStreamPlayer

var star_texture_rect := TextureRect.new()
var half_star_texture_rect := TextureRect.new()
var empty_star_texture_rect := TextureRect.new()
var value_to_show_on_bank_total: float


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

	const STAR_SIZE := Vector2(150, 150)

	star_texture_rect.texture = Global.star_texture
	star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	star_texture_rect.custom_minimum_size = STAR_SIZE
	star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#star_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND
	star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	half_star_texture_rect.texture = Global.half_star_texture
	half_star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	half_star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	half_star_texture_rect.custom_minimum_size = STAR_SIZE
	half_star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#half_star_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND
	half_star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	empty_star_texture_rect.texture = Global.empty_star_texture
	empty_star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	empty_star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	empty_star_texture_rect.custom_minimum_size = STAR_SIZE
	empty_star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#empty_star_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND
	empty_star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	button.pressed.connect(
		func():
			Events.end_screen_finished.emit()
	)


func _physics_process(_delta: float) -> void:
	bank_total.text = "🏦 Bank total: [color=gold]%s[/color]" % Global.float_to_price(value_to_show_on_bank_total)

	if visible:
		Global.in_end_screen = true
	else:
		Global.in_end_screen = false


func draw_stars() -> void:
	var current_rating := Global.employee_rating
	var rating_is_even := current_rating % 2 == 0
	var rating_shown := 0

	const DELAY_BETWEEN_STARS := 0.1

	if rating_is_even:
		for i in current_rating / 2.0:
			await get_tree().create_timer(DELAY_BETWEEN_STARS).timeout
			rating_stars_hbox.add_child(star_texture_rect.duplicate())
			rating_shown += 1
	else:
		for i in (current_rating - 1) / 2.0:
			await get_tree().create_timer(DELAY_BETWEEN_STARS).timeout
			rating_stars_hbox.add_child(star_texture_rect.duplicate())
			rating_shown += 1
		await get_tree().create_timer(DELAY_BETWEEN_STARS).timeout
		rating_stars_hbox.add_child(half_star_texture_rect.duplicate())
		rating_shown += 1

	for i in 5 - rating_shown:
		await get_tree().create_timer(DELAY_BETWEEN_STARS).timeout
		rating_stars_hbox.add_child(empty_star_texture_rect.duplicate())


func _on_time_up() -> void:
	# show time up screen
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()

	# show money breakdown
	var daily_profit := Global.daily_profit
	var daily_profit_goal: float = Stats.current.daily_profit_goal
	var our_cut := daily_profit - daily_profit_goal
	if our_cut < 0:
		our_cut = 0

	profit.text = "[color=green]+[/color] money made today: %s" % Global.float_to_price(daily_profit)
	boss_cut.text = "[color=red]-[/color] boss's cut: %s" % Global.float_to_price(daily_profit_goal)
	banked_today.text = "= [color=gold]%s[/color] banked" % Global.float_to_price(our_cut)
	profit.modulate.a = 0
	boss_cut.modulate.a = 0
	banked_today.modulate.a = 0
	money_calculation_screen.show()
	pencil_scribble.play()
	var calc_screen_tween := create_tween()
	calc_screen_tween.tween_property(profit, "modulate:a", 1, 0.2)
	calc_screen_tween.tween_property(boss_cut, "modulate:a", 1, 0.2)
	calc_screen_tween.tween_property(banked_today, "modulate:a", 1, 0.2)

	await get_tree().create_timer(2).timeout

	bank_total.show()
	value_to_show_on_bank_total = Global.bank_money
	Global.bank_money += our_cut
	await get_tree().create_timer(1).timeout
	if Global.bank_money > value_to_show_on_bank_total:
		bank_gain_sound.play()
		var t := create_tween().tween_property(
			self,
			"value_to_show_on_bank_total",
			Global.bank_money,
			0.75,
		)
		await t.finished
	await get_tree().create_timer(1).timeout

	# show stars
	rating_breakdown.show()
	draw_stars()
	stars_sound.play()
	await get_tree().create_timer(2).timeout

	# show passed/fired and button
	if (
			Global.daily_profit >= Stats.current.daily_profit_goal
			and Global.employee_rating >= Stats.current.employee_rating_goal
	):
		outcome.text = "[b][color=green]SHIFT CLEARED"
		button.text = "continue"
		win_shift_sound.play()
	else:
		outcome.text = "[b][color=red]FIRED"
		button.text = "new run"
		lose_shift_sound.play()

	outcome.show()

	await get_tree().create_timer(0.5).timeout

	button.show()
