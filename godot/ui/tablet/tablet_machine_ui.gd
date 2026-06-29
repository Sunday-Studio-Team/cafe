class_name TabletMachineUI
extends Control

@export var timer_ui: TextureProgressBar
@export var broken_down_text: Label
@export var ready_text: Label
@export var price_label: Label
@export var rating_label: Label

var machine: Machine

@onready var timer := machine.timer


func _physics_process(_delta: float) -> void:
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

		var score := machine.order.score
		rating_label.modulate = Color.GREEN if score > 0 else Color.RED
		rating_label.text = "+%s🙂" % score if score > 0 else "%s🙂" % score
