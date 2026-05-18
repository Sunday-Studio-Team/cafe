extends Node3D

@export var customer_queue: CustomerQueue

func _ready() -> void:
	Events.customer_approached_window.connect(_on_customer_approached_window)
	

func _on_customer_approached_window(customer: Customer) -> void:
	customer_queue.add_customer(customer)
