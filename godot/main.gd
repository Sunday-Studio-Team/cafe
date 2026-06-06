extends Node3D

@export var machines: Array[Machine]
@export var customer_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var game_timer: Timer
@export var window: Node3D
#Minigame
@export var minigame_controller: CanvasLayer


func _ready() -> void:
	Global.main_scene = self
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot

	customer_spawn_timer.timeout.connect(_on_customer_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.shift_started.connect(_on_shift_started)
	Events.customer_approached_machine.connect(_on_customer_approached_machine)

	#Connect minigame
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_end.connect(_on_minigame_end)

	# we have to set these manually here so if we reload the scene theyll reset
	Stats.daily_profit = 0
	Stats.employee_rating = 0

	# spawn one customer early off-sync with the timers wait time
	# so we dont have to wait loads every time we start the game to test
	# NOTE: commenting this out for now since maybe its better to give people
	# a few seconds to read the tutorial text and get their bearings
	#await get_tree().create_timer(1, false).timeout
	#customer_spawn_timer.timeout.emit()


func _on_customer_spawn_timer_timeout() -> void:
	var all_machines_occupied := true
	for machine in machines:
		if not machine.customer:
			all_machines_occupied = false
	if all_machines_occupied:
		return

	var customer = customer_scene.instantiate()
	customer.position = spot_for_customer_entry.position
	add_child(customer)
	await get_tree().create_timer(randf_range(2, 4), false).timeout
	Events.customer_approached_machine.emit(customer)


func _on_game_timer_timeout() -> void:
	Events.time_up.emit()
	await get_tree().create_timer(5, false).timeout
	get_tree().call_deferred("reload_current_scene")


func _on_customer_approached_machine(customer: Customer) -> void:
	var machine: Machine = null
	while machine == null or machine.customer:
		machine = machines.pick_random()

	machine.customer = customer


#Minigame is active (Need to turn off regular player controls)
func _on_minigame_active():
	minigame_controller.play_minigame("Colors")


#Closes the game -> Game is no longer visible and removed from the tree
#Player regains all regular controls etc
func _on_minigame_end():
	minigame_controller.close_game()


func _on_shift_started():
	game_timer.start()
	customer_spawn_timer.start()
