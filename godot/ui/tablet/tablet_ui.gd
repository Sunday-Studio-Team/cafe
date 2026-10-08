class_name TabletUi
extends Control

@export var money_made_label: Label
@export var money_bar: ProgressBar
@export var rating_label: Label
@export var customer_flow_rate_label: Label
@export var item_icons: Control

var _employee_rating_last_update: float = -1


func _ready() -> void:
	await get_tree().process_frame
	populate_items()
	Events.items_updated.connect(populate_items)


func populate_items() -> void:
	var i := 0
	for icon: TabletItemIcon in item_icons.get_children():
		if Global.owned_items.size() >= i + 1:
			icon.item = Global.owned_items[i]
		else:
			icon.item = null
		i += 1


func _physics_process(_delta: float) -> void:
	update_score_indicators()
	_update_rating()


func update_score_indicators() -> void:
	money_made_label.text = "%s/%s" % [
		Global.float_to_price(Global.daily_cafe_money),
		int(Stats.current.daily_profit_goals_each_day[Global.day])
	]

	if Global.daily_cafe_money:
		money_bar.value = Global.daily_cafe_money / Stats.current.daily_profit_goals_each_day[Global.day] * 100

	if not Global.employee_rating == _employee_rating_last_update:
		_update_rating()


func _update_rating() -> void:
	var current_rating: float = Global.employee_rating
	_employee_rating_last_update = current_rating

	rating_label.text = "⭐ %s / %s" % [current_rating, Stats.current.employee_rating_max]
	customer_flow_rate_label.text = "%.1f" % Global.machine_customer_flow_rate
