class_name CustomerQueue
extends Node3D

signal customer_added

static var seen_complaint_popup := false

@export var customer_interactable: Interactable
@export var front_of_window_queue: Marker3D
@export var queue_spacing_offset: float = -1

var customers_waiting: Array[Customer]

@onready var queue_front_position: Vector3 = front_of_window_queue.global_position


func _ready() -> void:
	customer_interactable.interacted.connect(_on_customer_interactable_interacted)
	customer_interactable.visible = false


func add_customer(customer: Customer) -> void:
	# Showing the popup tutorial when the customer complains
	if not seen_complaint_popup:
		seen_complaint_popup = true # Only showing it once
		Global.popups["complaint"].open()
	else:
		pass

	Events.alert_posted.emit("🛎️ customer complained")
	Global.score_update_message = "customer complained"

	customers_waiting.append(customer)
	customer.timer.timeout.connect(func(): remove_front_customer(false))
	await _on_queue_updated()
	customer_added.emit()
	customer.at_window = true
	customer.timer.wait_time = Stats.current.customer_wait_time_window
	customer.timer.start()
	customer.waiting_indicator.show()


func remove_front_customer(customer_happy: bool) -> void:
	# --------------------------------------------------
	# Code to satisfy front customer, should be moved to its own function once trigger to make drink is added
	# Or should be changed to call some function/emit the customer's signal telling them to do the next thing
	# maybe the customer should have the all around "next-step code", that gets called, and that chooses whether they leave or go to the window
	var front_customer: Customer = _get_front_customer()
	front_customer.body.modulate = Color(1.0, 1.0, 1.0, 1.0)
	front_customer.leave_store()
	# --------------------------------------------------

	customers_waiting.pop_front()
	await _on_queue_updated()

	if customer_happy:
		Global.score_update_message = "customer placated"
		Global.employee_rating += Stats.current.placated_customer_rating_gain_each_day[Global.day]
	else:
		Global.score_update_message = "customer left"
		Events.customer_timed_out_window.emit()


func _get_front_customer() -> Customer:
	return customers_waiting.front()


func _on_queue_updated() -> void:
	for index in customers_waiting.size():
		var customer: Customer = customers_waiting[index]
		# Offset z coordinate by the customer's position in the queue
		var customer_position: Vector3 = queue_front_position
		customer_position.z += queue_spacing_offset * index

		await customer.move_to(customer_position)

	# Update interactable
	if customers_waiting.size() > 0:
		customer_interactable.visible = true
	else:
		customer_interactable.visible = false


func _on_customer_interactable_interacted() -> void:
	Global.active_helpdesk_customer = _get_front_customer()

	Events.minigame_end.connect(_on_minigame_end)
	Events.minigame_cancelled.connect(_on_minigame_cancelled)
	Events.minigame_active.emit("Typing")
	Events.customer_timed_out_window.connect(_on_customer_timed_out_window)


func _on_minigame_end() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)
	Events.customer_timed_out_window.disconnect(_on_customer_timed_out_window)
	remove_front_customer(true)


func _on_minigame_cancelled() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)
	Events.customer_timed_out_window.disconnect(_on_customer_timed_out_window)


func _on_customer_timed_out_window() -> void:
	Events.force_close_minigame.emit()
