class_name Main
extends Node3D

@export var _emails_manager: EmailsManager
@export var _pause_menu: PauseMenu
@export var _tutorial_manager: TutorialManager
@export var _world_environment: WorldEnvironment
@export var _left_area_camera: SecurityCam3D
@export var _middle_camera: SecurityCam3D
@export var _right_area_camera: SecurityCam3D
@export var _hallway_camera: SecurityCam3D
@export var menu: Menu3D
@export var _right_area_left_machine: Machine
@export var _right_area_right_machine: Machine
@export var _left_area_left_machine: Machine
@export var _left_area_middle_machine: Machine
@export var _left_area_right_machine: Machine
@export var _customer_help_desk: CustomerHelpDesk
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var game_timer: Timer
@export var ui: CanvasLayer
@export var day_indicator: Label
@export var desk: Desk
@export var pc_ui: PC_UI
@export var overtime_item: Item
# environmental art that mentions security cams (referenced so we can disable
# them until the day where the cameras get installed)
@export var camera_posters: Array[Node3D]
#Minigame
@export var minigame_controller: CanvasLayer
#Active Items
@export var clock_item_stop_sound: AudioStreamPlayer
@export var clock_item_start_sound: AudioStreamPlayer
@export var teleporter1: Teleporter
@export var teleporter2: Teleporter
@export var teleporter3: Teleporter
@export var tutorial_selection_menu: TutorialSelectionMenu
@export var whiteboard_tutorial_arrow: Arrow3D
@export var waypoint_ring: Area3D
@export var shift_start_sound: AudioStreamPlayer

var _machine_customer_spawn_timer: Timer
var _help_desk_customer_spawn_timer: Timer

@export var _tutorial_vo_location_start_shift: VoiceLineLocation
@export var _tutorial_vo_location_machine_ui: VoiceLineLocation
@export var _tutorial_vo_location_ingredients_bag: VoiceLineLocation
@export var _tutorial_vo_location_help_desk: VoiceLineLocation
@export var _tutorial_vo_location_spill: VoiceLineLocation

var seen_tutorial_machine_instructions: bool = false
var _all_machines: Array[Machine]
var _active_machines: Array[Machine]
var _all_security_cameras: Array[SecurityCam3D]

@onready var tutorial_machine: Machine = _right_area_right_machine

var closing_time:bool = false

func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)
	SaveDataManager.get_options_data().apply_options()
	Events.customer_leave.connect(shift_end_sequence)
	Global.main_scene = self
	Events.main_scene_loaded.emit()
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot
	Global.shift_started = false
	
	_all_machines = [
		_right_area_left_machine,
		_right_area_right_machine,
		_left_area_left_machine,
		_left_area_middle_machine,
		_left_area_right_machine,
	]
	
	_all_security_cameras = [
		_left_area_camera,
		_middle_camera,
		_right_area_camera,
		_hallway_camera,
	]

	Events.employee_rating_updated.connect(_on_employee_rating_updated)
	
	_machine_customer_spawn_timer = Timer.new()
	add_child(_machine_customer_spawn_timer)
	_machine_customer_spawn_timer.timeout.connect(_on_machine_customer_spawn_timer_timeout)
	_machine_customer_spawn_timer.autostart = false
	
	_help_desk_customer_spawn_timer = Timer.new()
	add_child(_help_desk_customer_spawn_timer)
	_help_desk_customer_spawn_timer.timeout.connect(_on_help_desk_customer_spawn_timer_timeout)
	_help_desk_customer_spawn_timer.autostart = false
	
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.shift_started.connect(_on_shift_started)

	desk.interactable.interacted.connect(_on_desk_interacted)

	#Connect minigame
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_end.connect(_on_minigame_end)

	set_per_day_stuff()
	spawn_machines()
	enable_disable_teleporters()
	Events.items_updated.connect(get_stats)

	# we have to set these manually here so if we reload the scene theyll reset
	Global.holding_ingredients = false
	Global.daily_cafe_money = 0
	Global.employee_rating = 0
	Global.spills_this_shift = 0
	Global.breakdowns_this_shift = 0
	Global.in_machine_ui = false
	Global.machine_in_use = null
	Global.in_pc_ui = false
	Global.machine_customer_flow_rate = _get_machine_customer_flow_rate()
	Global.help_desk_customer_flow_rate = _get_help_desk_customer_flow_rate()
	get_stats()

	_pause_menu.tutorial_requested.connect(_on_pause_menu_tutorial_requested)

	for ui_element: Control in ui.find_children("*", "Control", false):
		ui_element.modulate = Color.TRANSPARENT

	day_indicator.text = Global.day_to_string(Global.day).to_upper()
	day_indicator.show()
	await create_tween().tween_property(day_indicator, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT).finished
	await get_tree().create_timer(3, false).timeout
	await create_tween().tween_property(day_indicator, "modulate", Color.TRANSPARENT, 0.5).finished
	day_indicator.hide()

	for ui_element: Control in ui.find_children("*", "Control", false):
		create_tween().tween_property(ui_element, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT)

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

	#if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
		#Global.popups["special shift"].open()

	if Global.day == 0:
		Events.tutorial_selected.connect(_interactive_tutorial_flow)

		if not SaveDataManager.save_data.finished_or_skipped_tutorial:
			tutorial_selection_menu.open_menu()
		else:
			_interactive_tutorial_flow()
	else:
		pass
		# whiteboard_tutorial_arrow.visible = false
		# waypoint_ring.hide()


func _process(delta: float) -> void:
	Global.shift_time_remaining = game_timer.time_left
	Global.shift_progress_ratio = (Global.shift_length - Global.shift_time_remaining) / Global.shift_length
	
	for item in Global.owned_items:
		if item.is_active_item:
			if item.active_item_remaining_cooldown > 0.0:
				item.active_item_remaining_cooldown -= delta
				if item.active_item_remaining_cooldown <= 0.0:
					item.can_be_used = true
					item.active_item_remaining_cooldown = 0


func get_stats() -> void:
	_machine_customer_spawn_timer.wait_time = Global.machine_customer_flow_rate
	_help_desk_customer_spawn_timer.wait_time = Global.help_desk_customer_flow_rate

	var shift_length: float = Stats.current.shift_lengths_for_each_day[Global.day]
	Global.shift_length = shift_length
	game_timer.wait_time = shift_length

	# if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
	# 	Global.current_special_shift.apply_stats()

	enable_disable_teleporters()


func enable_disable_teleporters():
	var has_teleporter: bool = false
	var has_teleporter_level_2: bool = false
	for item in Global.owned_items:
		if item.item_id == "teleporter":
			has_teleporter = true
			if item.item_level == 2:
				has_teleporter_level_2 = true
			break
	if has_teleporter:
		teleporter1.enable_teleporter()
		teleporter2.enable_teleporter()
		if has_teleporter_level_2:
			teleporter3.enable_teleporter()
		else:
			teleporter3.disable_teleporter()
	else:
		teleporter1.disable_teleporter()
		teleporter2.disable_teleporter()
		teleporter3.disable_teleporter()


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:
	closing_time = false
	if Global.day == 0:
		Global.player_tips_bank = 0
		Global.owned_items.clear()
		Stats.reset()
		Stats.current.customer_wait_time_machine = INF
		Stats.current.machine_chance_of_spill = 0.0
		_active_machines.clear()
		_active_machines.push_front(tutorial_machine)
		_set_day_security_cameras_active([])
	else:
		_on_desk_interacted()
		pc_ui._on_shop_button_pressed()
	if Global.day == 1:
		# Reset run.
		Global.player_tips_bank = 5
		Global.received_emails.clear()
		Global.read_emails.clear()
		Global.spam_emails.clear()
		Global.received_reviews.clear()
		Global.player_tips_bank = 0
		Global.owned_items.clear()
		Stats.reset()

	if Global.day == 1:
		_active_machines.clear()
		_active_machines.push_back(_right_area_left_machine)
		_active_machines.push_back(_right_area_right_machine)
		_set_day_security_cameras_active([])

	if Global.day == 2:
		_active_machines.clear()
		_active_machines.push_back(_left_area_right_machine)
		_active_machines.push_back(_right_area_left_machine)
		_set_day_security_cameras_active([_middle_camera])
	
	if Global.day == 3:
		_active_machines.clear()
		_active_machines.push_back(_left_area_right_machine)
		_active_machines.push_back(_right_area_left_machine)
		_active_machines.push_back(_right_area_right_machine)
		_set_day_security_cameras_active([_middle_camera, _right_area_camera])

	if Global.day == 4:
		_active_machines.clear()
		_active_machines.push_back(_left_area_left_machine)
		_active_machines.push_back(_left_area_right_machine)
		_active_machines.push_back(_right_area_left_machine)
		_active_machines.push_back(_right_area_right_machine)
		_set_day_security_cameras_active([_left_area_camera, _middle_camera, _right_area_camera])

	if Global.day == 5:
		_active_machines.clear()
		_active_machines.push_back(_left_area_left_machine)
		_active_machines.push_back(_left_area_middle_machine)
		_active_machines.push_back(_left_area_right_machine)
		_active_machines.push_back(_right_area_left_machine)
		_active_machines.push_back(_right_area_right_machine)
		_set_day_security_cameras_active([_left_area_camera, _middle_camera, _right_area_camera, _hallway_camera])
	
	_emails_manager.deliver_emails()
	menu.populate_drinks()
	
	Global.machines.assign(_active_machines)


func spawn_machines():
	for machine: Machine in _all_machines:
		machine.hide()
		machine.process_mode = Node.PROCESS_MODE_DISABLED

	for machine: Machine in _active_machines:
		machine.process_mode = Node.PROCESS_MODE_INHERIT
		machine.show()


func _on_machine_customer_spawn_timer_timeout() -> void:
	if closing_time: return
	_machine_customer_spawn_timer.wait_time = Global.machine_customer_flow_rate
	_machine_customer_spawn_timer.start()
	spawn_machine_customer()

func _on_help_desk_customer_spawn_timer_timeout() -> void:
	if closing_time: return
	_help_desk_customer_spawn_timer.wait_time = Global.help_desk_customer_flow_rate
	_help_desk_customer_spawn_timer.start()
	spawn_help_desk_customer()

func spawn_machine_customer() -> void:
	
	var available_machines: Array[Machine] = []
	for machine in _active_machines:
		if machine.queued_customers.size() < Stats.current.max_customers_queued_per_machine:
			available_machines.append(machine)
	
	if available_machines.size() == 0:
		return
	
	# Get the machine that's got the shortest queue.
	var shortest_queue_machine: Machine = null
	for machine in available_machines:
		if shortest_queue_machine == null:
			shortest_queue_machine = machine
			continue
		if machine.customer == null and shortest_queue_machine.customer != null:
			shortest_queue_machine = machine
			continue
		if machine.queued_customers.size() < shortest_queue_machine.queued_customers.size():
			shortest_queue_machine = machine
			continue
	
	var assigned_machine: Machine = shortest_queue_machine
	if assigned_machine == null:
		printerr("Machine to spawn at should never be null?")
		return
	
	var new_customer: Customer = customer_scene.instantiate()
	new_customer.position = spot_for_customer_entry.position
	add_child(new_customer)

	assigned_machine.add_customer_to_queue(new_customer)

func get_customers() -> Array[Customer]:
	return (get_tree().get_nodes_in_group("customer")) as Array[Customer]

func spawn_help_desk_customer() -> void:
	if _customer_help_desk.customer_queue_size() >= Stats.current.max_customers_queued_help_desk:
		return
	
	var new_customer: Customer = customer_scene.instantiate()
	new_customer.position = spot_for_customer_entry.position
	add_child(new_customer)
	
	_customer_help_desk.add_customer_to_queue(new_customer)

#Actives the effects of a given active item
func active_item_used(item: Item):
	if item.item_id == "air_freshener":
		var customer_wait_duration_extension: float = 0.0
		if item.item_level == 1:
			customer_wait_duration_extension = 20.0
		else:
			customer_wait_duration_extension = 30.0
		
		for machine in _active_machines:
			if machine.customer:
				machine.customer.extend_wait_patience_time(customer_wait_duration_extension)

		Global.put_active_item_on_cooldown(item)

		Events.alert_posted.emit("+%ss to all customers' patience!" % customer_wait_duration_extension)


func _set_day_security_cameras_active(cameras_to_set_active: Array[SecurityCam3D]) -> void:
	for security_camera in _all_security_cameras:
		if security_camera in cameras_to_set_active:
			security_camera.visible = true
		else:
			security_camera.visible = false


func _on_pause_menu_tutorial_requested() -> void:
	_tutorial_manager.show_tutorial()


func _on_game_timer_timeout() -> void:
	closing_time = true
	if get_customers().is_empty():
		shift_end_sequence()

func shift_end_sequence():
	if not closing_time and not get_customers().is_empty(): return
	Engine.time_scale = 1
	Events.time_up.emit()

	await Events.end_screen_finished

	get_tree().paused = false
	var met_profit_goal: bool = Global.daily_cafe_money >= Stats.current.daily_profit_goals_each_day[Global.day]
	if met_profit_goal:
		var just_finished_final_day: bool = Global.day == Global.final_day
		if just_finished_final_day:
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)
			return
		Global.day += 1
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
		#Leaving this here in case you guys want this scene back again
		#Events.scene_switch_requested.emit(SceneSwitcher.GameScene.END_OF_DAY_DIALOG_SCENE)
	else:
		Global.day = 1
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)


#Minigame is active (Need to turn off regular player controls)
func _on_minigame_active(minigame_name: String):
	minigame_controller.play_minigame(minigame_name)


#Closes the game -> Game is no longer visible and removed from the tree
#Player regains all regular controls etc
func _on_minigame_end():
	minigame_controller.close_game()


func _on_shift_started():
	Global.shift_started = true
	shift_start_sound.play()

	if Global.day > 0:
		game_timer.start()
		_machine_customer_spawn_timer.start(Stats.current.first_machine_customer_entry_time)
		_help_desk_customer_spawn_timer.start(Stats.current.first_help_desk_customer_entry_time)
		
		var has_scrubber: bool = false
		for item in Global.owned_items:
			if item.item_id == "super_scrubber":
				has_scrubber = true
				break
		DraggableMop.used_scrubber = has_scrubber

		desk.interactable.visible = false


func _interactive_tutorial_flow():
	_tutorial_manager.show_intro_tutorial()
	
	await _tutorial_manager.finished_tutorial
	
	# Start voice guidance
	_interactive_tutorial_shift()
	
	tutorial_machine.gui_3d.interactable.interacted.connect(
		func():
			if Global.day == 0 and not seen_tutorial_machine_instructions:
				_tutorial_manager.show_machine_tutorial()
				seen_tutorial_machine_instructions = true
	)


func _interactive_tutorial_shift() -> void:
	if tutorial_machine == null:
		printerr("Missing tutorial machine?")
		return
	
	await get_tree().create_timer(0.5, false).timeout
		
	var tutorial_intro_lines: Array[String] = [
		"tutorial_intro_1",
		"tutorial_intro_2",
		"tutorial_intro_3",
		"tutorial_intro_4",
		"tutorial_intro_5",
	]
	
	for i in range(tutorial_intro_lines.size()):
		var voice_line_id: String = tutorial_intro_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.shift_started and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.shift_started:
			break
	
	print("shift started: %s" % Global.shift_started)
	
	const REPEAT_INSTRUCTION_TIMER_DURATION: float = 10.0
	
	var repeat_instruction_timer: Timer = Timer.new()
	repeat_instruction_timer.autostart = false
	repeat_instruction_timer.one_shot = true
	add_child(repeat_instruction_timer)
	
	while !Global.shift_started:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_start_shift", _tutorial_vo_location_start_shift)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	var tutorial_shift_started_lines: Array[String] = [
		"tutorial_shift_started_1",
		"tutorial_shift_started_2",
	]
	
	Global.tutorial_machine_used = false
	for i in range(tutorial_shift_started_lines.size()):
		var voice_line_id: String = tutorial_shift_started_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.tutorial_machine_used and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.tutorial_machine_used:
			break
		
	while !Global.tutorial_machine_used:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_use_machine", _tutorial_vo_location_machine_ui)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_machine_used")
	
	# First customer, accept order
	tutorial_machine.force_next_drink_perfect()
	spawn_machine_customer()
	tutorial_machine.set_order_action_buttons_available("accept")
	
	await tutorial_machine.drink_prepared
	
	var tutorial_correct_drink_prepared_lines: Array[String] = [
		"tutorial_correct_drink_prepared_1",
		"tutorial_correct_drink_prepared_2",
	]
	
	Global.tutorial_drink_accepted = false
	for i in range(tutorial_correct_drink_prepared_lines.size()):
		var voice_line_id: String = tutorial_correct_drink_prepared_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.tutorial_drink_accepted and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.tutorial_drink_accepted:
			break
	
	while !Global.tutorial_drink_accepted:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_no_location("tutorial_accept_correct_drink")
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await get_tree().create_timer(0.5, false).timeout
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_correct_drink_accepted_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_correct_drink_accepted_2")
	
	# Second customer, manually remake drink
	tutorial_machine.force_next_drink_incorrect()
	spawn_machine_customer()
	tutorial_machine.set_order_action_buttons_available("make_drink")
	
	await tutorial_machine.drink_prepared
	
	var tutorial_incorrect_drink_prepared_lines: Array[String] = [
		"tutorial_incorrect_drink_prepared_1",
		"tutorial_incorrect_drink_prepared_2",
		"tutorial_incorrect_drink_prepared_3",
		"tutorial_incorrect_drink_prepared_4",
		"tutorial_incorrect_drink_prepared_5",
		"tutorial_incorrect_drink_prepared_6",
		"tutorial_incorrect_drink_prepared_7",
	]
	
	Global.tutorial_remake_button_pressed = false
	for i in range(tutorial_incorrect_drink_prepared_lines.size()):
		var voice_line_id: String = tutorial_incorrect_drink_prepared_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.tutorial_remake_button_pressed and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.tutorial_remake_button_pressed:
			break
	
	while !Global.tutorial_remake_button_pressed:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_no_location("tutorial_remake_drink")
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	var tutorial_remaking_drink_lines: Array[String] = [
		"tutorial_remaking_drink_1",
		"tutorial_remaking_drink_2",
		"tutorial_remaking_drink_3",
		"tutorial_remaking_drink_4",
	]
	
	Global.tutorial_drink_remade = false
	for i in range(tutorial_remaking_drink_lines.size()):
		var voice_line_id: String = tutorial_remaking_drink_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.tutorial_drink_remade and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.tutorial_drink_remade:
			break
	
	while !Global.tutorial_drink_remade:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_no_location("tutorial_remaking_drink_5")
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await get_tree().create_timer(0.5, false).timeout
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_drink_remade_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_drink_remade_2")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_drink_remade_3")
	
	# Machine runs out of ingredients: player learns to refill without a customer.
	tutorial_machine.customer = null
	tutorial_machine.waiting_for_response = false
	tutorial_machine.ingredients = 0
	tutorial_machine.no_ingredients_sound.play()
	tutorial_machine.set_order_action_buttons_available("refill")
	
	var tutorial_get_ingredients_lines: Array[String] = [
		"tutorial_get_ingredients_1",
		"tutorial_get_ingredients_2",
	]
	
	Global.tutorial_ingredients_bag_got = false
	for i in range(tutorial_get_ingredients_lines.size()):
		var voice_line_id: String = tutorial_get_ingredients_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while !Global.tutorial_ingredients_bag_got and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if Global.tutorial_ingredients_bag_got:
			break
	
	while !Global.tutorial_ingredients_bag_got:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_get_ingredients_3", _tutorial_vo_location_ingredients_bag)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_ingredients_got")
	
	while tutorial_machine.ingredients <= 0:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_no_location("tutorial_refill_machine")
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	tutorial_machine.set_order_action_buttons_available("all")
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_machine_refilled_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_machine_refilled_2")
	
	spawn_help_desk_customer()
	await _customer_help_desk.new_desk_customer_arrived
	
	await get_tree().create_timer(0.25, false).timeout
	
	var tutorial_help_desk_lines: Array[String] = [
		"tutorial_help_desk_1",
		"tutorial_help_desk_2",
		"tutorial_help_desk_3",
		"tutorial_help_desk_4",
	]
	
	for i in range(tutorial_help_desk_lines.size()):
		var voice_line_id: String = tutorial_help_desk_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while _customer_help_desk.has_active_customers() and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if !_customer_help_desk.has_active_customers():
			break
	
	while _customer_help_desk.has_active_customers():
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_help_desk_5", _tutorial_vo_location_help_desk)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_customer_helped_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_customer_helped_2")
	
	# Spill tutorial: player learns to clean up spills
	tutorial_machine.spill()
	
	await get_tree().create_timer(0.5, false).timeout
	
	var tutorial_machine_spilled_lines: Array[String] = [
		"tutorial_machine_spilled_1",
		"tutorial_machine_spilled_2",
	]
	
	for i in range(tutorial_machine_spilled_lines.size()):
		var voice_line_id: String = tutorial_machine_spilled_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while tutorial_machine.spill_on_floor and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if !tutorial_machine.spill_on_floor:
			break
	
	while tutorial_machine.spill_on_floor:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_machine_spilled_3", _tutorial_vo_location_spill)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_spill_cleaned_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_spill_cleaned_2")
	
	await get_tree().create_timer(0.5, false).timeout
	
	tutorial_machine.break_down()
	
	var tutorial_machine_broke_lines: Array[String] = [
		"tutorial_machine_broke_1",
		"tutorial_machine_broke_2",
		"tutorial_machine_broke_3",
	]
	
	for i in range(tutorial_machine_broke_lines.size()):
		var voice_line_id: String = tutorial_machine_broke_lines[i]
		Global.voice_line_system.play_voice_line_no_location(voice_line_id)
		while tutorial_machine.broken_down and Global.voice_line_system.is_playing_no_location_voice_line():
			await get_tree().process_frame
		if !tutorial_machine.broken_down:
			break
	
	while tutorial_machine.broken_down:
		if repeat_instruction_timer.time_left == 0.0:
			Global.voice_line_system.play_voice_line_at_location("tutorial_machine_broke_4", _tutorial_vo_location_machine_ui)
			repeat_instruction_timer.start(REPEAT_INSTRUCTION_TIMER_DURATION)
		else:
			await get_tree().process_frame
	repeat_instruction_timer.stop()
	
	await Global.voice_line_system.play_voice_line_no_location("tutorial_finished_1")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_finished_2")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_finished_3")
	await Global.voice_line_system.play_voice_line_no_location("tutorial_finished_4")
	
	var replaying_tutorial = SaveDataManager.save_data.finished_or_skipped_tutorial
	
	SaveDataManager.save_data.finished_or_skipped_tutorial = true
	SaveDataManager.save_game()

	if replaying_tutorial:
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)
	else:
		Global.day = 1
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)


func _on_desk_interacted() -> void:
	ui.hide()
	pc_ui.show()


func _on_game_options_changed(options_data: OptionsData) -> void:
	_apply_game_options(options_data)


func _apply_game_options(options_data: OptionsData) -> void:
	match options_data.graphics_preset:
		OptionsData.GraphicsOptionsPresets.HIGH:
			_world_environment.environment.ssao_enabled = true
			_world_environment.environment.ssil_enabled = true
			_world_environment.environment.sdfgi_enabled = true
			_world_environment.environment.volumetric_fog_enabled = true
			ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", false)
			ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_4X)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_4X)
		OptionsData.GraphicsOptionsPresets.MEDIUM:
			_world_environment.environment.ssao_enabled = true
			_world_environment.environment.ssil_enabled = false
			_world_environment.environment.sdfgi_enabled = true
			_world_environment.environment.volumetric_fog_enabled = false
			ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", true)
			ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_2X)
		OptionsData.GraphicsOptionsPresets.LOW:
			_world_environment.environment.ssao_enabled = false
			_world_environment.environment.ssil_enabled = false
			_world_environment.environment.sdfgi_enabled = false
			_world_environment.environment.volumetric_fog_enabled = false
			ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", true)
			ProjectSettings.set_setting("rendering/scaling_3d/scale", 1.0)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED)
		OptionsData.GraphicsOptionsPresets.MINIMUM:
			_world_environment.environment.ssao_enabled = false
			_world_environment.environment.ssil_enabled = false
			_world_environment.environment.sdfgi_enabled = false
			_world_environment.environment.volumetric_fog_enabled = false
			ProjectSettings.set_setting("rendering/global_illumination/gi/use_half_resolution", true)
			ProjectSettings.set_setting("rendering/scaling_3d/scale", 0.5)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED)
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_DISABLED)
		_:
			pass
	RenderingServer.gi_set_use_half_resolution(ProjectSettings.get_setting("rendering/global_illumination/gi/use_half_resolution"))
	if not is_inside_tree():
		await tree_entered
	get_viewport().scaling_3d_scale = (ProjectSettings.get_setting("rendering/scaling_3d/scale") as float)
	get_viewport().msaa_2d = (ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_2d") as Viewport.MSAA)
	get_viewport().msaa_3d = (ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d") as Viewport.MSAA)


func _on_employee_rating_updated(_new_value: float, _old_value: float) -> void:
	var new_machine_customer_flow_rate: float = _get_machine_customer_flow_rate()
	Global.machine_customer_flow_rate = new_machine_customer_flow_rate
	if _machine_customer_spawn_timer.time_left > new_machine_customer_flow_rate:
		_machine_customer_spawn_timer.wait_time = new_machine_customer_flow_rate
		_machine_customer_spawn_timer.start()

	var new_help_desk_customer_flow_rate: float = _get_help_desk_customer_flow_rate()
	Global.help_desk_customer_flow_rate = new_help_desk_customer_flow_rate
	if _help_desk_customer_spawn_timer.time_left > new_help_desk_customer_flow_rate:
		_help_desk_customer_spawn_timer.wait_time = new_help_desk_customer_flow_rate
		_help_desk_customer_spawn_timer.start()


func _get_machine_customer_flow_rate() -> float:
	return _rating_to_machine_customer_flow_rate(Global.employee_rating)

func _get_help_desk_customer_flow_rate() -> float:
	return _rating_to_help_desk_customer_flow_rate(Global.employee_rating)

## In seconds per machine customer entry.
func _rating_to_machine_customer_flow_rate(current_employee_rating: float) -> float:
	var rating_flow_rate_curve_for_day: Curve = Stats.current.machine_customer_flow_rate_at_rating_curve_per_day[Global.day]
	var current_employee_rating_ratio: float = current_employee_rating / Stats.current.employee_rating_max
	var seconds_per_customer: float = rating_flow_rate_curve_for_day.sample(current_employee_rating_ratio)
	print("secs per machine customer: %.1f" % seconds_per_customer)
	return seconds_per_customer

## In seconds per help desk customer entry.
func _rating_to_help_desk_customer_flow_rate(current_employee_rating: float) -> float:
	var rating_flow_rate_curve_for_day: Curve = Stats.current.help_desk_customer_flow_rate_at_rating_curve_per_day[Global.day]
	var current_employee_rating_ratio: float = current_employee_rating / Stats.current.employee_rating_max
	var seconds_per_customer: float = rating_flow_rate_curve_for_day.sample(current_employee_rating_ratio)
	print("secs per help desk customer: %.1f" % seconds_per_customer)
	return seconds_per_customer
