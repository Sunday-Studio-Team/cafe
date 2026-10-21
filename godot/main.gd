class_name Main
extends Node3D

@export var _emails_manager: EmailsManager
@export var _voice_line_system: VoiceLineSystem
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
@export var customer_help_desk: CustomerHelpDesk
@export var customer_trash_spawn_timer: Timer
@export var customer_scene: PackedScene
@export var customer_trash_scene: PackedScene
@export var spot_for_customer_entry: Marker3D
@export var customer_leaving_spot: Marker3D
@export var cafe_front_roller_shutters: CafeFrontRollerShutters
@export var game_timer: Timer
@export var ui: CanvasLayer
@export var _trash_can: TrashCan
@export var _shift_end_screen_scene_uid: StringName
@export var _shift_end_screen_container: Node

@export var _main_scene_loading_overlay: Control

@export var _player_shift_start_position: Node3D
@export var _shift_start_sequence_label: RichTextLabel
@export var _shift_start_countdown_sound: AudioStreamPlayer

# Lazy spawned break room nodes
@export var _desk_scene_uid: StringName
@export var _desk_container: Node
@export var _whiteboard_scene_uid: StringName
@export var _whiteboard_container: Node
@export var _locker_scene_uid: StringName
@export var _locker_container: Node
@export var _item_loadout_menu_scene_uid: StringName
@export var _item_loadout_menu_container: Node
var _nodes_to_destroy_on_shift_start: Array[Node]

@export var default_trash_spawn_spot: Marker3D

var _machine_customer_spawn_timer: Timer
var _help_desk_customer_spawn_timer: Timer

@export var day_containers_desk: Array[Node3D] = []
@export var day_containers_boxes: Array[Node3D] = []
@export var day_containers_posters: Array[Node3D] = []

var _all_machines: Array[Machine]
var _active_machines: Array[Machine]
var _all_security_cameras: Array[SecurityCam3D]

var tutorial_machine: Machine

var should_spawn_trash_today: bool = false
var closing_time: bool = false


func _ready() -> void:
	_main_scene_loading_overlay.visible = true
	_main_scene_loading_overlay.modulate.a = 1.0

	# Hide the view first, while lazy loading things.
	await lazy_spawn_node(_desk_scene_uid, _desk_container)
	await lazy_spawn_node(_whiteboard_scene_uid, _whiteboard_container)
	await lazy_spawn_node(_locker_scene_uid, _locker_container)
	await lazy_spawn_node(_item_loadout_menu_scene_uid, _item_loadout_menu_container)

	_voice_line_system.setup()
	Global.camera_mode = Global.CameraMode.PLAYER
	Global.cinematic_camera_allow_machine_gui_inputs = true

	_world_environment.environment = Global.cafe_environment_res
	Events.customer_leave.connect(shift_end_sequence)
	Events.spawn_specific_customer.connect(spawn_specific_customer)
	Events.air_freshener_used.connect(apply_used_air_freshener)
	Events.shutters_open_requested.connect(_on_shutters_open_requested)
	Events.shift_start_requested.connect(_on_shift_start_requested)
	Global.main_scene = self
	Global.customer_entry_spot = spot_for_customer_entry
	Global.customer_leaving_spot = customer_leaving_spot
	Global.shift_started = false

	customer_trash_spawn_timer.timeout.connect(attempt_spawn_trash)
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

	# Determine if we should play the tutorial!
	var should_play_tutorial: bool = (
		Global.day > SaveDataManager.save_data.latest_tutorial_completed_day
	)
	var skip_tutorials: bool = OS.has_feature("skip_tutorials")
	if should_play_tutorial and not skip_tutorials:
		print("should play tutorial!")
		Global.playing_tutorial = true
	else:
		Global.playing_tutorial = false
		print("should not play tutorial!")

	if not Global.playing_tutorial:
		Global.employee_rating = 2

	set_per_day_stuff()
	Events.items_updated.connect(get_stats)

	# enables props as the days go by
	# could combine the loops to one loop but am not sure if all props will have equivalent
	# number of day props
	for i in range(day_containers_desk.size()):
		if day_containers_desk[i] != null:
			day_containers_desk[i].visible = (i <= Global.day)

	for i in range(day_containers_boxes.size()):
		var box: Node3D = day_containers_boxes[i]
		if box != null:
			var should_show_box: bool = i <= Global.day
			if should_show_box:
				box.show()
				box.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
			else:
				box.hide()
				box.process_mode = Node.ProcessMode.PROCESS_MODE_DISABLED

	for i in range(day_containers_posters.size()):
		if day_containers_posters[i] != null:
			day_containers_posters[i].visible = (i <= Global.day)

	# we have to set all these manually here so if we reload the scene they'll reset
	Global.holding_ingredients = false
	Global.holding_trash = false
	Global.daily_cafe_money = 0
	Global.spills_this_shift = 0
	Global.breakdowns_this_shift = 0
	Global.in_machine_ui = false
	Global.machine_in_use = null
	Global.in_pc_ui = false
	Global.machine_customer_flow_rate = _get_machine_customer_flow_rate()
	Global.help_desk_customer_flow_rate = _get_help_desk_customer_flow_rate()
	Global.total_trash = 0
	Global.all_3d_audio_stream_players.clear()
	Global.refresh_active_items()
	closing_time = false

	get_stats()

	Events.main_scene_ready.emit()

	_tutorial_manager.start_day()


func _physics_process(delta: float) -> void:
	Global.shift_time_remaining = game_timer.time_left
	Global.shift_progress_ratio = (Global.shift_length - Global.shift_time_remaining) / Global.shift_length

	for item in Global.owned_items:
		if item.is_active_item:
			if Global.playing_tutorial:
				item.can_be_used = false
			else:
				if item.active_item_remaining_cooldown > 0.0:
					if Global.no_cooldowns:
						item.active_item_remaining_cooldown = 0
					else:
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


# we reload this main scene to start each day, so we set all the per-day stuff here
func set_per_day_stuff() -> void:

	if Global.day == 1:
		if Global.playing_tutorial:
			_active_machines.clear()
			tutorial_machine = _right_area_right_machine
			_active_machines.push_back(tutorial_machine)
			_set_day_security_cameras_active([])
		else:
			_active_machines.clear()
			_active_machines.push_back(_right_area_left_machine)
			_active_machines.push_back(_right_area_right_machine)
			_set_day_security_cameras_active([])
		_trash_can.visible = false

	if Global.day == 2:
		if Global.playing_tutorial:
			_active_machines.clear()
			tutorial_machine = _left_area_right_machine
			_active_machines.push_back(tutorial_machine)
			_set_day_security_cameras_active([])
		else:
			_active_machines.clear()
			_active_machines.push_back(_left_area_right_machine)
			_active_machines.push_back(_left_area_left_machine)
			_set_day_security_cameras_active([])
		_trash_can.visible = false

	if Global.day == 3:
		if Global.playing_tutorial:
			_active_machines.clear()
			tutorial_machine = _right_area_right_machine
			_active_machines.push_back(tutorial_machine)
			_set_day_security_cameras_active([_middle_camera])
		else:
			_active_machines.clear()
			_active_machines.push_back(_left_area_right_machine)
			_active_machines.push_back(_right_area_left_machine)
			_active_machines.push_back(_right_area_right_machine)
			_set_day_security_cameras_active([_middle_camera])
		_trash_can.visible = false

	if Global.day == 4:
		if Global.playing_tutorial:
			_active_machines.clear()
			_active_machines.push_back(_left_area_left_machine)
			_active_machines.push_back(_left_area_right_machine)
			_active_machines.push_back(_right_area_left_machine)
			_active_machines.push_back(_right_area_right_machine)
			_set_day_security_cameras_active([_left_area_camera, _middle_camera, _right_area_camera])
			should_spawn_trash_today = false
			_trash_can.visible = true
		else:
			_active_machines.clear()
			_active_machines.push_back(_left_area_left_machine)
			_active_machines.push_back(_left_area_right_machine)
			_active_machines.push_back(_right_area_left_machine)
			_active_machines.push_back(_right_area_right_machine)
			_set_day_security_cameras_active([_left_area_camera, _middle_camera, _right_area_camera])
			should_spawn_trash_today = true
			_trash_can.visible = true

	if Global.day == 5:
		_active_machines.clear()
		_active_machines.push_back(_left_area_left_machine)
		_active_machines.push_back(_left_area_middle_machine)
		_active_machines.push_back(_left_area_right_machine)
		_active_machines.push_back(_right_area_left_machine)
		_active_machines.push_back(_right_area_right_machine)
		_set_day_security_cameras_active(
			[_left_area_camera, _middle_camera, _right_area_camera, _hallway_camera]
		)
		should_spawn_trash_today = true
		_trash_can.visible = true

	_emails_manager.deliver_emails()
	menu.populate_drinks()

	for machine: Machine in _all_machines:
		machine.hide()
		machine.process_mode = Node.PROCESS_MODE_DISABLED

	for machine: Machine in _active_machines:
		machine.process_mode = Node.PROCESS_MODE_INHERIT
		machine.show()

	Global.machines.assign(_active_machines)


func _on_shutters_open_requested() -> void:
	cafe_front_roller_shutters.open()


func _on_shift_start_requested() -> void:
	if Global.playing_tutorial:
		Events.shift_started.emit()
	else:
		_shift_start_sequence_label.visible = false
		_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
		_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
		_tutorial_manager._cinematic_camera.enable_cinematic_camera(0.5)
		await _tutorial_manager._cinematic_camera.play_animation("pre_shift_start_sequence")
		Global.player.global_position = _player_shift_start_position.global_position
		Global.player.global_rotation = _player_shift_start_position.global_rotation
		_tutorial_manager._cinematic_camera.camera_rig_node.global_position = Global.player.camera.camera_effects.global_position
		_tutorial_manager._cinematic_camera.camera_rig_node.global_rotation = Global.player.camera.camera_effects.global_rotation
		await _tutorial_manager._cinematic_camera.play_animation("shift_start_sequence")
		_shift_start_sequence_label.visible = true
		_tutorial_manager._cinematic_camera.disable_cinematic_camera(3.0)
		_shift_start_countdown_sound.play()
		_shift_start_sequence_label.text = "3"
		# NOTE: can this get messsed up if the player pauses ?
		await get_tree().create_timer(1.0).timeout
		_shift_start_sequence_label.text = "2"
		await get_tree().create_timer(1.0).timeout
		_shift_start_sequence_label.text = "1"
		await get_tree().create_timer(1.0).timeout
		_shift_start_sequence_label.text = "GO!"
		Events.shift_started.emit()
		await get_tree().create_timer(1.0).timeout
		_shift_start_sequence_label.visible = false


func _on_machine_customer_spawn_timer_timeout() -> void:
	if closing_time:
		return
	_machine_customer_spawn_timer.wait_time = Global.machine_customer_flow_rate
	_machine_customer_spawn_timer.start()
	spawn_machine_customer()


func _on_help_desk_customer_spawn_timer_timeout() -> void:
	if closing_time:
		return
	_help_desk_customer_spawn_timer.wait_time = Global.help_desk_customer_flow_rate
	_help_desk_customer_spawn_timer.start()
	spawn_help_desk_customer()


func spawn_machine_customer(sprite_resource: CustomerSpriteData = null) -> void:
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
	if sprite_resource:
		new_customer.customer_sprite_resource = sprite_resource
		Console.print_line("spawned %s at machine" % sprite_resource.customer_name)

	assigned_machine.add_customer_to_queue(new_customer)


func get_customers() -> Array[Customer]:
	return (get_tree().get_nodes_in_group("customer")) as Array[Customer]


func spawn_specific_customer(customer_name: String, help_desk: String) -> void:
	var help_desk_bool := help_desk == "true"
	var customer_sprite_data: CustomerSpriteData = null
	for datum in Global.customer_sprites:
		if datum.customer_name.to_lower() == customer_name.to_lower():
			customer_sprite_data = datum
			break
	if customer_sprite_data == null:
		customer_sprite_data = Global.customer_sprites.pick_random()

	if help_desk_bool:
		spawn_help_desk_customer(customer_sprite_data)
	else:
		spawn_machine_customer(customer_sprite_data)


func spawn_help_desk_customer(sprite_resource: CustomerSpriteData = null) -> void:
	if customer_help_desk.customer_queue_size() >= Stats.current.max_customers_queued_help_desk:
		return

	# NOTE: NOTE SURE WHAT THIS IS DOING
	# Allow help desk on tutorial day for now
	if Global.day > 0:
		# Disallow help desk if not unlocked yet
		if Global.day < 2:
			if sprite_resource != null:
				Console.print_line("help desk disabled today, cant spawn customer")
			return

	var new_customer: Customer = customer_scene.instantiate()
	new_customer.position = spot_for_customer_entry.position
	add_child(new_customer)
	if sprite_resource:
		new_customer.customer_sprite_resource = sprite_resource
		Console.print_line("spawned %s at help desk" % sprite_resource.customer_name)
	customer_help_desk.add_customer_to_queue(new_customer)


func apply_used_air_freshener(customer_wait_duration_extension: float) -> void:
	for machine in _active_machines:
		if machine.customer:
			machine.customer.extend_wait_patience_time(customer_wait_duration_extension)


func _set_day_security_cameras_active(cameras_to_set_active: Array[SecurityCam3D]) -> void:
	for security_camera in _all_security_cameras:
		if security_camera in cameras_to_set_active:
			security_camera.visible = true
		else:
			security_camera.visible = false


func attempt_spawn_trash() -> void:
	if not should_spawn_trash_today:
		return

	# freq of spawn 3/41 rn
	# TODO: move this probability to Stats ?
	var spawn := randi_range(0, 40)
	if spawn >= 3:
		return

	spawn_trash()


func spawn_trash() -> void:
	var customer_trash: CustomerTrash = customer_trash_scene.instantiate()

	var current_customers: Array[Customer]
	# Get all current customer positions
	for child in get_children():
		if child is Customer:
			current_customers.append(child)

	var littering_customer: Customer = null
	if current_customers.size() > 0:
		littering_customer = current_customers.pick_random()
	if littering_customer:
		customer_trash.position = Vector3(
			littering_customer.global_position.x,
			0,
			littering_customer.global_position.z,
		)
	else:
		customer_trash.position = default_trash_spawn_spot.position
		print("no customers exist, trash was generate at default location")
	print("spawned trash")

	add_child(customer_trash, true)

	Global.total_trash += 1
	if Global.total_trash >= Global.trash_punishment_threshold:
		if Global.lucky_charm_check():
			Events.alert_posted.emit("Too much trash in the store", UI.AlertIconType.RATING, UI.ALERT_DEFAULT_DURATION, UI.ALERT_COLOR_RED)
			Events.alert_posted.emit("Lucky! Rating loss prevented!", UI.AlertIconType.RATING, UI.ALERT_DEFAULT_DURATION, UI.ALERT_COLOR_NEUTRAL)
		else:
			Events.alert_posted.emit( "-%s Too much trash in the store" % Global.trash_punishment_amount, UI.AlertIconType.RATING, UI.ALERT_DEFAULT_DURATION, UI.ALERT_COLOR_RED)
			Global.employee_rating -= Global.trash_punishment_amount
	Events.alert_posted.emit(
		"Customer dropped some trash...",
		UI.AlertIconType.CUSTOMER,
		UI.ALERT_DEFAULT_DURATION,
		UI.ALERT_COLOR_NEUTRAL,
	)


func _on_game_timer_timeout() -> void:
	free_customer_queue()
	Events.shift_end_sequence_started.emit()
	closing_time = true
	if get_customers().size() <= 1:
		shift_end_sequence()


func shift_end_sequence(override: bool = false):
	# Here's the thing. When a customer calls this function as they
	# are still leaving, they are still part of the scene tree.
	# So get_customers() will return an array that includes them.
	# That is why it checks for a customer array of size 1 (or less)
	if override or (closing_time and get_customers().size() <= 1):
		Engine.time_scale = 1
		Events.time_up.emit()

		# Create the shift end screen
		var token: ResourceBackgroundLoaderToken = Global.resource_background_loader.cache_resource(_shift_end_screen_scene_uid)
		while !token.is_loaded:
			await get_tree().process_frame
		var shift_end_screen_scene: PackedScene = Global.resource_background_loader.get_resource(token) as PackedScene
		Global.resource_background_loader.uncache_resource(token)
		if shift_end_screen_scene == null:
			printerr("shift_end_screen_scene is null!")
			return
		var shift_end_screen: ShiftEndScreen = shift_end_screen_scene.instantiate()
		_shift_end_screen_container.add_child(shift_end_screen)

		await Events.end_screen_finished

		get_tree().paused = false
		var met_profit_goal: bool = (
			Global.daily_cafe_money >= Stats.current.daily_profit_goals_each_day[Global.day]
		)
		if met_profit_goal:
			var just_finished_final_day: bool = Global.day == Global.final_day
			if just_finished_final_day:
				Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)
				return
			Global.day += 1

			if Global.day > SaveDataManager.save_data.latest_unlocked_day:
				SaveDataManager.save_data.latest_unlocked_day = Global.day
				SaveDataManager.save_game_to_file()

			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
		#Leaving this here in case you guys want this scene back again
		#Events.scene_switch_requested.emit(SceneSwitcher.GameScene.END_OF_DAY_DIALOG_SCENE)
		else:
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)

func lazy_spawn_node(scene_uid: StringName, node_container: Node) -> void:
	var token: ResourceBackgroundLoaderToken = Global.resource_background_loader.cache_resource(scene_uid)
	while !token.is_loaded:
		await get_tree().process_frame
	var scene: PackedScene = Global.resource_background_loader.get_resource(token)
	Global.resource_background_loader.uncache_resource(token)
	if scene == null:
		return
	var node: Node = scene.instantiate()
	node_container.add_child(node)
	_nodes_to_destroy_on_shift_start.append(node)


func free_customer_queue():
	for machine in _active_machines:
		var leaving_array: Array[Customer] = machine.queued_customers.duplicate()
		machine.queued_customers.clear()
		for customer in leaving_array: #Copied so no wack stuff happens
			customer.leave_store()

	var help_desk_leaving_array: Array[Customer] = customer_help_desk._queued_desk_customers.duplicate()
	customer_help_desk._queued_desk_customers.clear()
	for help_desk_customer in help_desk_leaving_array:
		help_desk_customer.leave_store()


func _on_shift_started():
	customer_trash_spawn_timer.start()
	Global.shift_started = true

	# Destroy break room nodes when the shift starts, save resources!
	for node in _nodes_to_destroy_on_shift_start:
		node.queue_free()

	if Global.day > 0:
		if not Global.playing_tutorial:
			game_timer.start()
			_machine_customer_spawn_timer.start(Stats.current.first_machine_customer_entry_time)
			_help_desk_customer_spawn_timer.start(Stats.current.first_help_desk_customer_entry_time)



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
	var rating_flow_rate_curve_for_day: Curve = (
		Stats.current.machine_customer_flow_rate_at_rating_curve_per_day[Global.day]
	)
	var current_employee_rating_ratio: float = (
		current_employee_rating / Stats.current.employee_rating_max
	)
	var seconds_per_customer: float = (
		rating_flow_rate_curve_for_day.sample(current_employee_rating_ratio)
	)
	return seconds_per_customer


## In seconds per help desk customer entry.
func _rating_to_help_desk_customer_flow_rate(current_employee_rating: float) -> float:
	var rating_flow_rate_curve_for_day: Curve = (
		Stats.current.help_desk_customer_flow_rate_at_rating_curve_per_day[Global.day]
	)
	var current_employee_rating_ratio: float = (
		current_employee_rating / Stats.current.employee_rating_max
	)
	var seconds_per_customer: float = (
		rating_flow_rate_curve_for_day.sample(current_employee_rating_ratio)
	)
	return seconds_per_customer
