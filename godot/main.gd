extends Node3D

static var seen_interaction_popup := false
static var seen_breakdown_popup := false

@export var _pause_menu: PauseMenu
@export var _tutorial_manager: TutorialManager
@export var _world_environment: WorldEnvironment
@export var machines: Array[Machine]
@export var _cameras: Array[SecurityCam3D]
@export var menu: Menu3D
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
@export var teleporter: Item
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


func _enter_tree() -> void:
	# for setting day on spawn (for debug)
	#Global.day = 5
	pass


func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)
	SaveDataManager.get_options_data().apply_options()
	
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

	if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
		Global.current_special_shift.unapply_stats()

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
		special_shift_text.text = Global.current_special_shift.description
		special_shift_title.text = Global.current_special_shift.name
		special_shift_icon.texture = Global.current_special_shift.icon
		Global.popups["special shift"].open()
	
	if teleporter in Global.owned_items:
		teleporter1.enable_teleporter()
		teleporter2.enable_teleporter()
	else:
		teleporter1.disable_teleporter()
		teleporter2.disable_teleporter()


func get_stats() -> void:
	customer_spawn_timer.wait_time = Stats.current.customer_spawn_interval
	if overtime_item in Global.owned_items:
		game_timer.wait_time += Stats.current.extra_time_from_overtime_form_item
	if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
		Global.current_special_shift.apply_stats()


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:
	if Global.day == 1:
		Global.bank_money = 0
		Global.owned_items.clear()
		Stats.reset()
	if Global.day >= 1:
		game_timer.wait_time = 90
		Stats.current.daily_profit_goal = 10
		_set_security_cameras_active(false)
	if Global.day >= 2:
		game_timer.wait_time = 120
		Stats.current.daily_profit_goal = 20
		machines.push_front(side_machine)
		side_machine.show()
		side_machine.process_mode = Node.PROCESS_MODE_INHERIT
	if Global.day >= 3:
		game_timer.wait_time = 120
		Stats.current.daily_profit_goal = 20
		_set_security_cameras_active(true)
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

	await machine.set_customer(new_customer)
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

func _set_security_cameras_active(active: bool) -> void:
	for security_camera in _cameras:
		security_camera.set_camera_visible(active)

func _on_pause_menu_tutorial_requested() -> void:
	_tutorial_manager.show_tutorial()


func _on_game_timer_timeout() -> void:
	Events.time_up.emit()

	await Events.end_screen_finished

	get_tree().paused = false
	var met_profit_goal: bool = Global.daily_profit >= Stats.current.daily_profit_goal
	var met_employee_rating_goal: bool = Global.employee_rating >= Stats.current.employee_rating_goal
	if met_profit_goal and met_employee_rating_goal:
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
	game_timer.start()
	customer_spawn_timer.start()
	desk.enabled = false


func _on_desk_interacted() -> void:
	ui.hide()
	pc_ui.show()


func _on_timer_timeout():
	#game_timer.paused = false
	pass # Replace with function body.


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
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", RenderingServer.ViewportMSAA.VIEWPORT_MSAA_2X)
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
	get_viewport().scaling_3d_scale = (ProjectSettings.get_setting("rendering/scaling_3d/scale") as float)
	get_viewport().msaa_2d = (ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_2d") as Viewport.MSAA)
	get_viewport().msaa_3d = (ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d") as Viewport.MSAA)
