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


func _ready() -> void:
	Events.time_up.connect(_on_time_up)


func _on_time_up() -> void:
	show()
	background.show()
	get_tree().paused = true
	times_up.show()
	#time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()

	if (
		Stats.daily_profit >= Stats.daily_profit_goal
		and Stats.employee_rating >= Stats.employee_rating_goal
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

	var daily_profit := Stats.daily_profit
	var daily_profit_goal := Stats.daily_profit_goal
	var our_cut := daily_profit - daily_profit_goal
	if our_cut < 0:
		our_cut = 0

	# TODO: animate these one by one
	money_calculation_screen.show()
	profit.text = "money made today: %s" % Global.float_to_price(daily_profit)
	boss_cut.text = "- boss's cut: %s" % Global.float_to_price(daily_profit_goal)
	banked_today.text = "= %s banked" % Global.float_to_price(our_cut)

	await get_tree().create_timer(5).timeout

	money_calculation_screen.hide()
	Stats.bank_money += our_cut
	bank_total.text = "🏦 bank total: %s" % Global.float_to_price(Stats.bank_money)
	bank_total.show()

	await get_tree().create_timer(4).timeout

	Events.end_screen_finished.emit()
