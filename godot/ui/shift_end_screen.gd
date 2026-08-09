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
@export var star_rating_textures: Array[Texture]
@export var stars_texure_rect: TextureRect
@export var rating_breakdown: Control
@export var button: Button
@export var stars_sound: AudioStreamPlayer
@export var _free_item_selector_screen_packed_scene: PackedScene
@export var _free_item_selector_screen_container: Control

var value_to_show_on_bank_total: float


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

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

	# show rating
	rating_breakdown.show()

	stars_texure_rect.texture = star_rating_textures[Global.employee_rating]

	var color_to_tint_stars: Color

	if Global.employee_rating >= Stats.current.employee_rating_goal:
		color_to_tint_stars = Color.GREEN
	else:
		color_to_tint_stars = Color.RED

	stars_sound.play()

	create_tween().tween_property(
		stars_texure_rect,
		"modulate",
		Color.WHITE,
		1,
	).from(color_to_tint_stars)

	await get_tree().create_timer(2).timeout

	# show outcome text and button
	if (
			Global.daily_profit >= Stats.current.daily_profit_goal
			and Global.employee_rating >= Stats.current.employee_rating_goal
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

	await get_tree().create_timer(0.5).timeout

	# If player has a free item slot,
	# and if 5 star customer satisfaction, give free selection of 1 of 3 random items
	var has_free_item_slots: bool = Global.owned_items.size() <= Global.item_slots_amount
	var made_enough_money: bool = Global.daily_profit >= Stats.current.daily_profit_goal
	var five_star_rating: int = 10
	var got_five_stars: bool = Global.employee_rating >= five_star_rating
	if has_free_item_slots and made_enough_money and got_five_stars:
		var free_item_selector_screen: FreeItemSelectorScreen = _free_item_selector_screen_packed_scene.instantiate()
		if free_item_selector_screen == null:
			printerr("FreeItemSelectorScreen is null.")
			return
		_free_item_selector_screen_container.add_child(free_item_selector_screen)
		await free_item_selector_screen.finished_selection
		free_item_selector_screen.queue_free()

	button.show()
