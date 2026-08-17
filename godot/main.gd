extends Node3D

static var seen_interaction_popup := false
static var seen_breakdown_popup := false

@export var _pause_menu: PauseMenu
@export var _tutorial_manager: TutorialManager
@export var _world_environment: WorldEnvironment
@export var _cameras: Array[SecurityCam3D]
@export var menu: Menu3D
# first machine on the left
@export var first_day_machines: Array[Machine]
@export var first_machine: Machine
@export var second_machine: Machine
@export var third_machine: Machine
@export var fourth_machine: Machine
@export var tutorial_machine: Machine
@export var customer_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var game_timer: Timer
@export var window: Node3D
@export var ui: CanvasLayer
@export var day_indicator: Label
@export var desk: Desk
@export var pc_ui: Control
@export var overtime_item: Item
@export var teleporter: Item
@export var scrubber: Item
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
@export var interaction_popup: CanvasLayer
@export var breakdown_popup: CanvasLayer
@export var special_shift_icon: TextureRect
@export var special_shift_text: Label
@export var special_shift_title: Label
@export var teleporter1: Teleporter
@export var teleporter2: Teleporter
@export var tutorial_selection_menu: TutorialSelectionMenu


var machines: Array[Machine]

var _previous_tracked_employee_rating: float = 0.0

func _enter_tree() -> void:
	# for setting day on spawn (for debug)
	#Global.day = 5
	pass


func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)
	SaveDataManager.get_options_data().apply_options()
	
	Global.main_scene = self
	Events.main_scene_loaded.emit()
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot
	Global.shift_started = false
	
	Events.employee_rating_updated.connect(_on_employee_rating_updated)
	customer_spawn_timer.timeout.connect(_on_customer_timer_timeout)
	customer_spawn_timer.autostart = false
	game_timer.timeout.connect(_on_game_timer_timeout)

	Events.shift_started.connect(_on_shift_started)

	desk.interactable.interacted.connect(_on_desk_interacted)

	#Connect minigame
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_end.connect(_on_minigame_end)

	set_per_day_stuff()
	enable_disable_teleporters()
	Events.items_updated.connect(get_stats)

	# we have to set these manually here so if we reload the scene theyll reset
	Global.holding_ingredients = false
	Global.daily_cafe_money = 0
	Global.employee_rating = 0
	Global.spills_this_shift = 0
	Global.breakdowns_this_shift = 0
	Global.in_machine_ui = false
	Global.in_pc_ui = false
	Global.customer_flow_rate = _get_customer_flow_rate()
	get_stats()

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

	if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
		Global.popups["special shift"].open()
	
	if Global.day == 0:
		tutorial_selection_menu.open_menu()



func get_stats() -> void:
	customer_spawn_timer.wait_time = Global.customer_flow_rate

	var shift_length: float = Stats.current.shift_lengths_for_each_day[Global.day]
	if Global.owned_items.has(overtime_item):
		shift_length += Stats.current.extra_time_from_overtime_form_item
	game_timer.wait_time = shift_length

	if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
		Global.current_special_shift.apply_stats()


func enable_disable_teleporters():
	if teleporter in Global.owned_items:
		teleporter1.enable_teleporter()
		teleporter2.enable_teleporter()
	else:
		teleporter1.disable_teleporter()
		teleporter2.disable_teleporter()


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:
	if Global.day == 0:
		Global.player_tips_bank = 0
		Global.owned_items.clear()
		Stats.reset()
		Stats.current.customer_wait_time_machine = INF
		Stats.current.chance_of_machine_breaking = 0.0
		Stats.current.machine_chance_of_spill = 0.0
		machines.clear()
		machines.push_front(tutorial_machine)
		load_machines()
		_set_security_cameras_active(false)
	if Global.day == 1:
		Global.player_tips_bank = 0
		Global.owned_items.clear()
		machines = first_day_machines
		Stats.reset()
		load_machines()
	if Global.day >= 1:
		_set_security_cameras_active(false)
	if Global.day >= 2:
		Stats.current.daily_profit_goal = 20
		machines.push_front(first_machine)
		load_machines()
	if Global.day >= 3:
		_set_security_cameras_active(true)
	if Global.day >= 4:
		Global.holding_ingredients_rule = true
	if Global.day == 5:
		machines.push_front(fourth_machine)
		load_machines()

	if Global.ai_improvement and !Global.ai_improvement_enabled:
		# actually add the stats now
		for stat in Global.ai_improvement.stat_bonuses:
			var current_stat = Stats.current.get(stat)
			if current_stat == null:
				push_error("email is trying to give a bonus to '%s' but that stat does not exist" % [stat])
			Stats.current.set(stat, current_stat + Global.ai_improvement.stat_bonuses[stat])
		Global.ai_improvement_enabled = true

	menu.populate_drinks()

	Global.machines.assign(machines)

	#select a special shift if it is not day one
	if Global.day > 1:
		var rng = RandomNumberGenerator.new()
		var weights: PackedFloat32Array
		for special_shift in Global.special_shifts:
			weights.append(special_shift.weight)

		var selected_index := rng.rand_weighted(weights)
		Global.current_special_shift = Global.special_shifts[selected_index]
	else:
		Global.current_special_shift = Global.special_shifts[0]


func load_machines():
	first_machine.hide()
	first_machine.process_mode = Node.PROCESS_MODE_DISABLED
	second_machine.hide()
	second_machine.process_mode = Node.PROCESS_MODE_DISABLED
	third_machine.hide()
	third_machine.process_mode = Node.PROCESS_MODE_DISABLED
	fourth_machine.hide()
	fourth_machine.process_mode = Node.PROCESS_MODE_DISABLED
	for machine in machines:
		machine.process_mode = Node.PROCESS_MODE_INHERIT
		machine.show()


func _on_customer_timer_timeout() -> void:
	customer_spawn_timer.wait_time = Global.customer_flow_rate
	customer_spawn_timer.start()
	spawn_customer()

func spawn_customer() -> void:
	var available_machines: Array[Machine] = []
	for machine in machines:
		if machine.queued_customers.size() < Stats.current.max_customers_queued_per_machine:
			available_machines.append(machine)
	
	if available_machines.size() == 0:
		return
	
	var assigned_machine: Machine = available_machines.pick_random()
	if assigned_machine == null:
		printerr("Machine to spawn at should never be null?")
		return
	
	var new_customer: Customer = customer_scene.instantiate()
	new_customer.position = spot_for_customer_entry.position
	add_child(new_customer)

	assigned_machine.add_customer_to_queue(new_customer)


#Actives the effects of a given active item
func active_item_used(item: Item):
	# TODO: Fix how clock works
	if item == clock_item and not game_timer.is_stopped():
		game_timer.paused = true
		Global.equipped_item = null
		Global.deactivate_active_item(item)
		clock_item_stop_sound.play()
		await get_tree().create_timer(8, false).timeout
		game_timer.paused = false
		clock_item_start_sound.play()


func _set_security_cameras_active(active: bool) -> void:
	for security_camera in _cameras:
		security_camera.visible = active


func _on_pause_menu_tutorial_requested() -> void:
	_tutorial_manager.show_tutorial()


func _on_game_timer_timeout() -> void:
	Events.time_up.emit()

	await Events.end_screen_finished

	get_tree().paused = false
	var met_profit_goal: bool = Global.daily_cafe_money >= Stats.current.daily_profit_goals_each_day[Global.day]
	if met_profit_goal:
		var just_finished_final_day: bool = Global.day == Global.final_day
		if just_finished_final_day:
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)
			return
		Events.scene_switch_requested.emit(SceneSwitcher.GameScene.END_OF_DAY_DIALOG_SCENE)
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

	if Global.day > 0:
		game_timer.start()
		customer_spawn_timer.start(Stats.current.first_customer_entry_time)

		if scrubber in Global.owned_items:
			DraggableMop.used_scrubber = true
		else:
			DraggableMop.used_scrubber = false

		desk.interactable.visible = false
	
	else:
		interactive_tutorial_flow()


func interactive_tutorial_flow() -> void:
	if tutorial_machine == null:
		return

	# First customer, accept order
	tutorial_machine.force_next_drink_perfect()
	spawn_customer()
	tutorial_machine.set_order_action_buttons_available("accept")

	while tutorial_machine.customer != null or tutorial_machine.queued_customers.size() > 0:
		await get_tree().process_frame
	await get_tree().create_timer(0.5, false).timeout

	# Third customer, make drink
	tutorial_machine.force_next_drink_incorrect()
	spawn_customer()
	tutorial_machine.set_order_action_buttons_available("make_drink")

	while tutorial_machine.customer != null or tutorial_machine.queued_customers.size() > 0:
		await get_tree().process_frame
	await get_tree().create_timer(0.5, false).timeout

	# Machine runs out of ingredients: player learns to refill without a customer.
	tutorial_machine.customer = null
	tutorial_machine.waiting_for_response = false
	tutorial_machine.ingredients = 0
	tutorial_machine.set_order_action_buttons_available("refill")

	while tutorial_machine.ingredients <= 0:
		await get_tree().process_frame

	tutorial_machine.set_order_action_buttons_available("all")

	# Spill tutorial: player learns to clean up spills
	tutorial_machine.spill()

	while tutorial_machine.spill_on_floor:
		await get_tree().process_frame
	
	tutorial_machine.break_down()

	while tutorial_machine.broken_down:
		await get_tree().process_frame
	
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

func _on_employee_rating_updated(new_value: float, old_value: float) -> void:
	var new_flow_rate: float = _get_customer_flow_rate()
	Global.customer_flow_rate = new_flow_rate
	if customer_spawn_timer.time_left > new_flow_rate:
		customer_spawn_timer.wait_time = new_flow_rate
		customer_spawn_timer.start()

func _get_customer_flow_rate() -> float:
	return _rating_to_customer_flow_rate(Global.employee_rating)

## In seconds per customer entry.
func _rating_to_customer_flow_rate(current_employee_rating: float) -> float:
	var min_flow_rate_for_day: float = Stats.current.customer_flow_rate_at_min_rating_per_day[Global.day]
	var max_flow_rate_for_day: float = Stats.current.customer_flow_rate_at_max_rating_per_day[Global.day]
	var seconds_per_customer: float = remap(current_employee_rating, 0.0, Stats.current.employee_rating_max, min_flow_rate_for_day, max_flow_rate_for_day)
	return seconds_per_customer
