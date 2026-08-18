extends CanvasLayer

@export var end_shift_button: Button
@export var continue_shift_button: Button
@export var game_timer: Timer
@export var main_label: Label
@export var secondary_label: Label

var requirements_met_before := false


func _ready() -> void:
	Events.money_updated.connect(_on_money_update)
	Events.employee_rating_updated.connect(_on_employee_rating_update)
	Events.time_up.connect(func(): requirements_met_before = false)

	end_shift_button.pressed.connect(end_shift)
	continue_shift_button.pressed.connect(close_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("end_shift_early_menu"):
		if requirements_met_before:
			if Global.in_end_shift_early_menu:
				close_menu()
			else:
				open_menu()
	elif event.is_action_pressed("pause"):
		if Global.in_end_shift_early_menu:
			close_menu()


func open_menu() -> void:
	update_label()
	Global.in_end_shift_early_menu = true
	get_tree().paused = true
	show()


func update_label() -> void:
	if (
			Global.daily_cafe_money >= Stats.current.daily_profit_goals_each_day[Global.day]
	):
		main_label.text = "All Requirements Are Met!"
		secondary_label.text = "You can end shift early at any time."
	else:
		main_label.text = "You Didn't Meet All Requirements!"
		secondary_label.text = "⚠️⚠️ Ending the shift will result in immediate FAILURE ⚠️⚠️"


func end_shift() -> void:
	close_menu()
	game_timer.stop()
	game_timer.timeout.emit()


func close_menu() -> void:
	Global.in_end_shift_early_menu = false
	get_tree().paused = false
	hide()


func _on_money_update(new: float, _old: float) -> void:
	if new >= Stats.current.daily_profit_goals_each_day[Global.day]:
		if !requirements_met_before:
			requirements_met_before = true
			_on_requirements_met()


func _on_employee_rating_update(new: int, _old: int) -> void:
	pass


func _on_requirements_met() -> void:
	show()
	Events.requirements_met.emit()
	Global.in_end_shift_early_menu = true
	get_tree().paused = true
