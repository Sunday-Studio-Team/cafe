class_name CustomerQueue
extends Node3D

signal customer_added
signal queue_updated

@export var front_of_window_queue: Marker3D
@export var queue_spacing_offset: float = -1

var customers_waiting: Array[Customer]

@onready var queue_front_position: Vector3 = front_of_window_queue.global_position


func _ready() -> void:
	queue_updated.connect(_on_queue_updated)


func add_customer(customer: Customer) -> void:
	Events.alert_posted.emit("❗️🛎️ customer complained")
	customers_waiting.append(customer)
	customer.timer.timeout.connect(func(): remove_front_customer(false))
	customer.drink_made_at_window.connect(func(): remove_front_customer(true))
	customer.make_drink_button.enabled = true
	queue_updated.emit()
	customer_added.emit()
	customer.at_window = true
	customer.timer.wait_time = Stats.customer_wait_time_window
	customer.timer.start()
	customer.waiting_indicator.show()


func remove_front_customer(customer_happy: bool) -> void:
	# --------------------------------------------------
	# Code to satisfy front customer, should be moved to its own function once trigger to make drink is added
	# Or should be changed to call some function/emit the customer's signal telling them to do the next thing
	# maybe the customer should have the all around "next-step code", that gets called, and that chooses whether they leave or go to the window
	var front_customer: Customer = get_front_customer()
	front_customer.body.modulate = Color(1.0, 1.0, 1.0, 1.0)
	front_customer.leave_store()
	# --------------------------------------------------

	customers_waiting.pop_front()
	queue_updated.emit()

	if customer_happy:
		Global.score_update_message = "fixed customer's drink"
		Stats.daily_profit += 3
	else:
		Global.score_update_message = "customer left"
		Stats.employee_rating -= 3


func get_front_customer() -> Customer:
	return customers_waiting.front()


func _on_queue_updated() -> void:
	for index in customers_waiting.size():
		var customer: Customer = customers_waiting[index]
		# Offset z coordinate by the customer's position in the queue
		var customer_position: Vector3 = queue_front_position
		customer_position.z += queue_spacing_offset * index

		customer.global_position = customer_position
