class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var customer_order_indicator: Label3D
@export var final_order_indicator: Label3D
@export var score_label: Label3D
@export var accept_button: Interactable
@export var reject_button: Interactable
@export var waiting_approval_indicator: Label3D
@export var making_drink_text: Label3D

var occupied := false:
	set(value):
		occupied = value
		if not occupied:
			customer = null
			customer_order_indicator.hide()
			final_order_indicator.hide()
			score_label.hide()
			return
		await get_tree().create_timer(randf_range(1, 3), false).timeout
		start_order()
var customer: Customer
var customers_order: Drink
var completed_order: Drink
var waiting_for_response: bool = false


func _ready() -> void:
	timer.timeout.connect(_on_order_finished)
	progress_bar.hide()
	making_drink_text.hide()
	score_label.hide()
	customer_order_indicator.hide()
	final_order_indicator.hide()

	accept_button.interacted.connect(_on_accept_button_presssed)
	reject_button.interacted.connect(_on_reject_button_pressed)


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100
	accept_button.visible = waiting_for_response
	reject_button.visible = waiting_for_response
	waiting_approval_indicator.visible = waiting_for_response


func start_order() -> void:
	timer.start()
	customers_order = Global.drinks.pick_random()
	customer_order_indicator.text = "customer ordered: " + customers_order.drink_name
	customer_order_indicator.show()
	progress_bar.show()
	making_drink_text.show()
	print("starting order")


func score_drink() -> void:
	var score := 0

	for element in ["main_ingredient", "liquid", "extra"]:
		if completed_order.get(element) == customers_order.get(element):
			score += 1
		else:
			score -= 1

	Global.score += score

	score_label.show()
	if score > 0:
		score_label.modulate = Color.GREEN_YELLOW
		score_label.text = "+ " + str(score)
	else:
		score_label.modulate = Color.RED
		score_label.text = str(score)


func _on_order_finished() -> void:
	progress_bar.hide()
	making_drink_text.hide()
	completed_order = Global.drinks.pick_random()
	final_order_indicator.text = "machine made: " + completed_order.drink_name
	final_order_indicator.show()
	waiting_for_response = true


func _on_accept_button_presssed() -> void:
	print("Accept was clicked")
	if (!waiting_for_response or completed_order == null):
		return
	final_order_indicator.text = "order approved! \n dispensing drink to customer"
	score_drink()
	waiting_for_response = false
	completed_order = null

	await get_tree().create_timer(randf_range(1, 2), false).timeout
	Events.customer_left_machine.emit(customer)
	occupied = false

	print("order finished")


func _on_reject_button_pressed() -> void:
	print("Reject was clicked")
	if (!waiting_for_response or timer.time_left > 0):
		return
	final_order_indicator.text = "order rejected! \n making a new drink"
	timer.start()
	progress_bar.show()
	making_drink_text.show()
	waiting_for_response = false
