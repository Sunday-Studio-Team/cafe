extends Node3D

@export var _pause_menu: PauseMenu
@export var _tutorial_manager: TutorialManager
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
@export var overtime_item: Item
# environmental art that mentions security cams (referenced so we can disable
# them until the day where the cameras get installed)
@export var camera_posters: Array[Node3D]
#Minigame
@export var minigame_controller: CanvasLayer
#Active Items
@export var clock_item: Item
@export var active_item_timer: Timer
@export var clock_item_stop_sound: AudioStreamPlayer
@export var clock_item_start_sound: AudioStreamPlayer


func _enter_tree() -> void:
	# for setting day on spawn (for debug)
	#Global.day = 5
	pass


func _ready() -> void:
	Global.main_scene = self
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot

	customer_spawn_timer.timeout.connect(spawn_customer)
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.shift_started.connect(_on_shift_started)

	desk.interacted.connect(_on_desk_interacted)

	#Connect minigame
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_end.connect(_on_minigame_end)

	set_per_day_stuff()
	get_stats()
	Events.items_updated.connect(get_stats)

	# we have to set these manually here so if we reload the scene theyll reset
	Global.holding_ingredients = false
	Global.daily_profit = 0
	Global.employee_rating = 0
	Global.spills_this_shift = 0
	Global.breakdowns_this_shift = 0
	Global.in_machine_ui = false
	Global.in_pc_ui = false

	# high values for debug
	#Global.daily_profit = 100
	#Global.employee_rating = 100
	#Global.bank_money = 100

	ui.hide()

	_pause_menu.tutorial_requested.connect(_on_pause_menu_tutorial_requested)
	if Global.day == 1:
		if not OS.has_feature("editor"):
			_tutorial_manager.show_tutorial()
			await _tutorial_manager.finished_tutorial

	day_indicator.text = "DAY %s" % Global.day
	day_indicator.show()
	await get_tree().create_timer(3, false).timeout
	if not Global.in_pc_ui:
		ui.show()
	day_indicator.hide()
	Input.set_custom_mouse_cursor(null)

	# spawn one customer early off-sync with the timers wait time
	# so we dont have to wait loads every time we start the game to test
	# NOTE: commenting this out for now since maybe its better to give people
	# a few seconds to read the tutorial text and get their bearings
	#await get_tree().create_timer(1, false).timeout
	#customer_spawn_timer.timeout.emit()

	#Active Item refresh
	Global.refresh_active_items()

	#Active Items
	Events.active_item_used.connect(active_item_used)


func get_stats() -> void:
	customer_spawn_timer.wait_time = Stats.current.customer_spawn_interval
	if overtime_item in Global.owned_items:
		game_timer.wait_time += Stats.current.extra_time_from_overtime_form_item


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:
	if Global.day == 1:
		Global.bank_money = 0
		Global.owned_items.clear()
		Stats.reset()
	if Global.day >= 1:
		game_timer.wait_time = 90
		Stats.current.daily_profit_goal = 18
		cameras.hide()
	if Global.day >= 2:
		game_timer.wait_time = 120
		Stats.current.daily_profit_goal = 27
		cameras.show()
	if Global.day >= 3:
		game_timer.wait_time = 120
		Stats.current.daily_profit_goal = 45
		machines.push_front(side_machine)
		side_machine.show()
		side_machine.process_mode = Node.PROCESS_MODE_INHERIT
	if Global.day >= 4:
		Global.holding_ingredients_rule = true
	if Global.day == 5:
		machines.push_front(fourth_machine)
		fourth_machine.show()
		fourth_machine.process_mode = Node.PROCESS_MODE_INHERIT

	if Global.ai_improvement and !Global.ai_improvement_enabled:
		# actually add the stats now
		for stat in Global.ai_improvement.stat_bonuses:
			var current_stat = Stats.current.get(stat)
			if current_stat == null:
				push_error("email is trying to give a bonus to '%s' but that stat does not exist" % [stat])
			Stats.current.set(stat, current_stat + Global.ai_improvement.stat_bonuses[stat])
		Global.ai_improvement_enabled = true

	Global.machines.assign(machines)

	# hide posters that mention security cameras until we have them
	if Global.day < 2:
		for poster in camera_posters:
			poster.hide()


func spawn_customer() -> void:
	var all_machines_occupied := true

	for machine in machines:
		if not machine.customer:
			all_machines_occupied = false

	if all_machines_occupied:
		return

	var new_customer = customer_scene.instantiate()
	new_customer.position = spot_for_customer_entry.position
	add_child(new_customer)

	await get_tree().create_timer(randf_range(2, 4), false).timeout

	var machine: Machine = null
	while machine == null or machine.customer:
		machine = machines.pick_random()

	machine.set_customer(new_customer)
	machine.machine_make_drink()


#Actives the effects of a given active item
func active_item_used(item: Item):
	var item_name: String = ""
	if item != null:
		item_name = item.name

	# TODO: Fix how clock works
	if item == clock_item and not game_timer.is_stopped():
		game_timer.paused = true
		Global.equipped_item = null
		Global.deactivate_active_item(item)
		clock_item_stop_sound.play()
		await get_tree().create_timer(8, false).timeout
		game_timer.paused = false
		clock_item_start_sound.play()


func _on_pause_menu_tutorial_requested() -> void:
	_tutorial_manager.show_tutorial()


func _on_game_timer_timeout() -> void:
	Events.time_up.emit()

	await Events.end_screen_finished

	get_tree().paused = false
	if (
			Global.daily_profit >= Stats.current.daily_profit_goal
			and Global.employee_rating >= Stats.current.employee_rating_goal
	):
		Global.day += 1
	else:
		Global.day = 1
	if Global.day == Global.final_day + 1:
		Events.main_menu_loaded.emit()
	else:
		Events.main_scene_loaded.emit()


#Minigame is active (Need to turn off regular player controls)
func _on_minigame_active(minigame_name: String):
	minigame_controller.play_minigame(minigame_name)


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


func _on_timer_timeout():
	#game_timer.paused = false
	pass # Replace with function body.
