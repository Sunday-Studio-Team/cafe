extends Node3D

@export var machines: Array[Machine]
@export var cameras: Node3D
# first machine on the left
@export var side_machine: Machine
@export var fourth_machine: Machine
@export var customer_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var game_timer: Timer
@export var window: Node3D
@export var ui: CanvasLayer
@export var day_indicator: Label
@export var desk: Interactable
@export var pc_ui: Control
#Minigame
@export var minigame_controller: CanvasLayer
#Active Items
@onready var clock_switch_timer = $ActivateItems/Clock_Switch_Timer


func _ready() -> void:
	Global.main_scene = self
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot

	customer_spawn_timer.timeout.connect(_on_customer_spawn_timer_timeout)
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.shift_started.connect(_on_shift_started)
	Events.customer_approached_machine.connect(_on_customer_approached_machine)

	desk.interacted.connect(_on_desk_interacted)

	#Connect minigame
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_end.connect(_on_minigame_end)

	set_per_day_stuff()

	# we have to set these manually here so if we reload the scene theyll reset
	Global.holding_ingredients = false
	Global.daily_profit = 0
	Global.employee_rating = 0
	# high values for debug
	#Global.daily_profit = 100
	#Global.employee_rating = 100
	#Global.bank_money = 100

	ui.hide()
	day_indicator.text = "DAY %s" % Global.day
	day_indicator.show()
	await get_tree().create_timer(3, false).timeout
	ui.show()
	day_indicator.hide()

	# spawn one customer early off-sync with the timers wait time
	# so we dont have to wait loads every time we start the game to test
	# NOTE: commenting this out for now since maybe its better to give people
	# a few seconds to read the tutorial text and get their bearings
	#await get_tree().create_timer(1, false).timeout
	#customer_spawn_timer.timeout.emit()
	
	#Active Item Use
	Events.active_item_used.connect(active_item_used)
	


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:
	if Global.day == 1:
		Global.bank_money = 0
		Global.owned_items.clear()
		Stats.reset()
	if Global.day >= 1:
		game_timer.wait_time = 80
		# since theres less happening in the first 'tutorial shift' we can make the machines
		# more likely to break there to introduce that mechanic in a safe environment
		Stats.current.chance_of_machine_breaking = 0.3
		Stats.current.daily_profit_goal = 15
		cameras.hide()
	if Global.day >= 2:
		game_timer.wait_time = 90
		Stats.current.chance_of_machine_breaking = 0.2
		Stats.current.daily_profit_goal = 20
		cameras.show()
	if Global.day >= 3:
		game_timer.wait_time = 120
		Stats.current.daily_profit_goal = 30
		machines.append(side_machine)
		side_machine.show()
	if Global.day >= 4:
		Global.holding_ingredients_rule = true
	if Global.day == 5:
		machines.append(fourth_machine)
		fourth_machine.show()


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
	await Events.end_screen_finished
	get_tree().paused = false
	if (
		Global.daily_profit > Stats.current.daily_profit_goal
		and Global.employee_rating > Stats.current.employee_rating_goal
	):
		Global.day += 1
	else:
		Global.day = 1
	if Global.day == Global.final_day + 1:
		get_tree().quit()
	else:
		Events.main_scene_loaded.emit()


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
	desk.enabled = false


func _on_desk_interacted() -> void:
	ui.hide()
	pc_ui.show()
	



#When an Item is used, will activate the required effects
func active_item_used(item: String):
	print(item)
	
	if item == "hammer":
		#Check if the player is in front of a machine:
		
		pass
	if item == "clock":
		#Stop the clock for a time period
		game_timer.stop()
		clock_switch_timer.start()



func _on_clock_switch_timer_timeout():
	game_timer.start()
	pass # Replace with function body.
