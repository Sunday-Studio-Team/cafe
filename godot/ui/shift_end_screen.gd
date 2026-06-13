extends CanvasLayer

@export var background: ColorRect
@export var times_up: RichTextLabel
@export var shift_cleared: RichTextLabel
@export var shift_failed: RichTextLabel
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

var value_to_show_on_bank_total: float


func _ready() -> void:
	Events.time_up.connect(_on_time_up)


func _physics_process(_delta: float) -> void:
	bank_total.text = "🏦 bank total: %s" % Global.float_to_price(value_to_show_on_bank_total)


func _on_time_up() -> void:
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()

	if (
		Global.daily_profit >= Stats.current.daily_profit_goal
		and Global.employee_rating >= Stats.current.employee_rating_goal
	):
		shift_cleared.show()
		win_shift_sound.play()
	else:
		shift_failed.show()
		lose_shift_sound.play()
		await get_tree().create_timer(3).timeout
		Events.end_screen_finished.emit()

	await get_tree().create_timer(3).timeout
	shift_cleared.hide()
	shift_failed.hide()

	var daily_profit := Global.daily_profit
	var daily_profit_goal := Stats.current.daily_profit_goal
	var our_cut := daily_profit - daily_profit_goal
	if our_cut < 0:
		our_cut = 0

	profit.text = "[color=green]+[/color] money made today: %s" % Global.float_to_price(daily_profit)
	boss_cut.text = "[color=red]-[/color] boss's cut: %s" % Global.float_to_price(daily_profit_goal)
	banked_today.text = "= %s banked" % Global.float_to_price(our_cut)
	profit.modulate.a = 0
	boss_cut.modulate.a = 0
	banked_today.modulate.a = 0
	money_calculation_screen.show()
	pencil_scribble.play()
	var calc_screen_tween := create_tween()
	calc_screen_tween.tween_property(profit, "modulate:a", 1, 0.2)
	calc_screen_tween.tween_property(boss_cut, "modulate:a", 1, 0.2)
	calc_screen_tween.tween_property(banked_today, "modulate:a", 1, 0.2)

	await get_tree().create_timer(5).timeout

	money_calculation_screen.hide()
	bank_total.show()
	Global.bank_money += our_cut
	await get_tree().create_timer(1).timeout
	if Global.bank_money > value_to_show_on_bank_total:
		bank_gain_sound.play()
		# TODO: figure out a way to do this that works while still having the bank total text
		# centre-aligned
		var t := create_tween().tween_property(
			self,
			"value_to_show_on_bank_total",
			Global.bank_money,
			1.5,
		)
		await t.finished
	await get_tree().create_timer(4).timeout
	Events.end_screen_finished.emit()
