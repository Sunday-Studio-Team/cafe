class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_indicator: Sprite3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var customer_order_indicator: Label3D
@export var final_order_indicator: Label3D
@export var score_label: Label3D
@export var make_drink_button: Interactable
@export var accept_button: Interactable
@export var reject_button: Interactable
@export var waiting_approval_indicator: Label3D

var customer: Customer:
	set(new_customer):
		customer = new_customer
		if customer:
			customer.global_position = spot_for_customer.global_position
			await get_tree().create_timer(randf_range(1, 3), false).timeout
			start_order()
		else:
			customer_order_indicator.hide()
			final_order_indicator.hide()
			score_label.hide()
var customers_order: Drink
var completed_order: Drink
var waiting_for_response: bool = false
var drink_score: int = 0


func _ready() -> void:
	accept_button.interacted.connect(_on_accept_button_presssed)
	reject_button.interacted.connect(_on_reject_button_pressed)
	make_drink_button.interacted.connect(_on_make_drink_button_pressed)
	timer.timeout.connect(_on_order_finished)

	progress_indicator.hide()
	score_label.hide()
	customer_order_indicator.hide()
	final_order_indicator.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100

	progress_indicator.visible = not timer.is_stopped()
	accept_button.visible = waiting_for_response
	reject_button.visible = waiting_for_response
	make_drink_button.visible = waiting_for_response
	waiting_approval_indicator.visible = waiting_for_response


func start_order() -> void:
	customers_order = Global.drinks.pick_random()
	customer_order_indicator.text = "customer ordered: " + customers_order.name
	print("customer's order is: ", customers_order.name)
	customer_order_indicator.show()
	timer.start()


func score_drink() -> void:
	drink_score = 0

	for element in ["main_ingredient", "liquid", "extra"]:
		if completed_order.get(element) == customers_order.get(element):
			drink_score += 1
		else:
			drink_score -= 1

	match drink_score:
		-3:
			score_label.modulate = Color.DARK_RED
			score_label.text = "-3 (drink TOTALLY wrong)"
		-1:
			score_label.modulate = Color.RED
			score_label.text = "-1 (drink mostly wrong)"
		+1:
			score_label.modulate = Color.GREEN_YELLOW
			score_label.text = "+1 (drink partially correct)"
		+3:
			score_label.modulate = Color.GREEN
			score_label.text = "+3 (drink correct)"

	score_label.show()


func _on_order_finished() -> void:
	completed_order = Global.drinks.pick_random()
	#completed_order = Global.full_wrong_drink # make every order fully wrong for testing
	final_order_indicator.text = "machine made: " + completed_order.name
	final_order_indicator.show()
	score_drink()
	waiting_for_response = true
	Events.order_completed.emit(customer)


func _on_accept_button_presssed() -> void:
	Events.order_approved.emit(customer)
	Global.score += drink_score
	final_order_indicator.text = "order approved! \n dispensing drink to customer"
	waiting_for_response = false
	completed_order = null

	# -------------------------------------------------
	# Check if the drink score is -3 to make them angry (red)
	# pretty clunky right now, with a score check here and a score check in _on_customer_left_machine
	if (drink_score <= -3):
		await get_tree().create_timer(randf_range(0.3, 1), false).timeout
		customer.body.modulate = Color(0.8, 0.3, 0.3, 1.0)
	# -------------------------------------------------

	await get_tree().create_timer(randf_range(1, 2), false).timeout
	Events.customer_left_machine.emit(customer, drink_score)
	customer = null

	print("order finished")


func _on_reject_button_pressed() -> void:
	final_order_indicator.text = "order rejected! \n making a new drink"
	timer.start()
	progress_indicator.show()
	waiting_for_response = false


func _on_make_drink_button_pressed() -> void:
	completed_order = customers_order
	final_order_indicator.text = "you made: " + completed_order.name
	score_drink()
	Events.order_completed.emit(customer)
