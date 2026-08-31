class_name TabletMachineUI
extends Control

@export var timer_ui: TextureProgressBar
@export var broken_down_text: Label
@export var ready_text: Label
@export var price_label: Label
@export var rating_label: Label
@export var spill: Control
@export var ingredients: Control
@export var customer_wait_indicator: Control
@export var customer_wait_bar: TextureProgressBar

var machine: Machine

@onready var timer := machine.timer


func _process(_delta: float) -> void:
	if timer.is_stopped():
		timer_ui.hide()
	else:
		timer_ui.show()
		timer_ui.value = (1 - timer.time_left / timer.wait_time) * 100

	broken_down_text.visible = machine.broken_down

	var waiting := machine.waiting_for_response
	ready_text.visible = waiting
	price_label.visible = waiting
	rating_label.visible = waiting

	if waiting:
		price_label.text = "+%s" % Global.float_to_price(machine.order.made_drink.price)

		var star_rating_gain_for_remake: float = machine.order.star_rating_gain_for_remake
		rating_label.modulate = Color.GREEN if star_rating_gain_for_remake > 0 else Color.DARK_GRAY
		rating_label.text = "+%s⭐️🙂" % star_rating_gain_for_remake if star_rating_gain_for_remake > 0 else ""

	spill.visible = machine.spill_on_floor

	ingredients.visible = machine.ingredients < Stats.current.ingredients_per_order

	if machine.customer == null:
		customer_wait_indicator.hide()
		return

	var customer_timer: Timer = machine.customer.timer
	if customer_timer != null and not customer_timer.is_stopped():
		customer_wait_indicator.show()

		customer_wait_bar.value = customer_timer.time_left / customer_timer.wait_time * 100

		if customer_wait_bar.value >= 66:
			customer_wait_indicator.modulate = Color.GREEN
		elif customer_wait_bar.value >= 33:
			customer_wait_indicator.modulate = Color.ORANGE
		else:
			customer_wait_indicator.modulate = Color.RED
	else:
		customer_wait_indicator.hide()
