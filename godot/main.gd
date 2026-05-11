extends Node3D

@export var machines: Array[Machine]
@export var customer_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D


func _ready() -> void:
	Global.main_scene = self

	customer_spawn_timer.timeout.connect(_on_customer_spawn_timer_timeout)

	Events.customer_approached_machine.connect(_on_customer_approached_machine)


func _on_customer_spawn_timer_timeout() -> void:
	var customer = customer_scene.instantiate()
	customer.position = spot_for_customer_entry.position
	add_child(customer)
	await get_tree().create_timer(randf_range(2, 4), false).timeout
	Events.customer_approached_machine.emit(customer)


func _on_customer_approached_machine(customer: Customer) -> void:
	var machine: Machine = null
	while machine == null or machine.occupied:
		machine = machines.pick_random()

	customer.global_position = machine.spot_for_customer.global_position
	machine.occupied = true
