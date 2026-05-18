class_name CustomerQueue
extends Node3D

signal queue_updated()

@export var front_of_window_queue: Marker3D
@export var queue_spacing_offset: float = 50

var customers_waiting: Array[Customer]

@onready var queue_front_position: Vector3 = front_of_window_queue.global_position


func _ready() -> void:
	queue_updated.connect(_on_queue_updated)


func add_customer(customer: Customer) -> void:
	customers_waiting.append(customer)
	queue_updated.emit()


func remove_front_customer() -> void:
	# --------------------------------------------------
	# Code to satisfy front customer, should be moved to its own function once trigger to make drink is added
	var front_customer: Customer = get_front_customer()
	front_customer.body.modulate = Color(1.0, 1.0, 1.0, 1.0)
	front_customer.leave_store()
	# --------------------------------------------------
	
	
	customers_waiting.pop_front()
	queue_updated.emit()


func get_front_customer() -> Customer:
	return customers_waiting.front()


func _on_queue_updated() -> void:
	for index in customers_waiting.size():
		var customer: Customer = customers_waiting[index]
		# Offset z coordinate by the customer's position in the queue
		var customer_position: Vector3 = queue_front_position
		customer_position.z += queue_spacing_offset * index
		
		customer.global_position = customer_position
