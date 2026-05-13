extends Node3D

@export var machines: Array[Machine]
@export var customer_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var game_timer: Timer


func _ready() -> void:
	Global.main_scene = self
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot

	customer_spawn_timer.timeout.connect(_on_customer_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.customer_approached_machine.connect(_on_customer_approached_machine)


func _on_customer_spawn_timer_timeout() -> void:
	# TODO: figure out how to have a queue of customers at door and/or at machines
	var existing_customers = get_tree().get_nodes_in_group("customers") as Array[Customer]
	if existing_customers.size() == machines.size():
		return

	var customer = customer_scene.instantiate()
	customer.position = spot_for_customer_entry.position
	add_child(customer)
	await get_tree().create_timer(randf_range(2, 4), false).timeout
	Events.customer_approached_machine.emit(customer)


func _on_game_timer_timeout() -> void:
	Events.time_up.emit()
	await get_tree().create_timer(5, false).timeout
	Global.score = 0
	get_tree().reload_current_scene()


func _on_customer_approached_machine(customer: Customer) -> void:
	var machine: Machine = null
	while machine == null or machine.customer:
		machine = machines.pick_random()

	customer.global_position = machine.spot_for_customer.global_position
	machine.occupied = true
	machine.customer = customer
