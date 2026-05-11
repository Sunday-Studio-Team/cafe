class_name Customer
extends Node3D


func _ready() -> void:
	Events.customer_left_machine.connect(_on_customer_left_machine)
	# NOTE: not actually sure what this true argument does here lol
	add_to_group("customers", true)

	print("spawned a customer")


func _exit_tree() -> void:
	print("customer despawned")


func _on_customer_left_machine(customer: Customer) -> void:
	if customer != self:
		return

	global_transform = Global.customer_leaving_spot.global_transform
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	queue_free()
