class_name Customer
extends Node3D


func _ready() -> void:
	Events.customer_left_machine.connect(_on_customer_left_machine)


func _on_customer_left_machine(customer: Customer) -> void:
	if customer != self:
		return

	global_transform = Global.customer_leaving_spot.global_transform
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	queue_free()
