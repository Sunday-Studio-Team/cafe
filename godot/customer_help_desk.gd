class_name CustomerHelpDesk
extends Node3D

signal new_desk_customer_arrived

@export var _spot_for_customer: Marker3D
@export var _start_of_customer_queue_marker: Marker3D
@export var _end_of_customer_queue_marker: Marker3D
@export var _help_desk_interactable: Interactable
@export var bell_sound: AudioStreamPlayer3D

var _desk_customer: Customer
var _queued_desk_customers: Array[Customer]

func _ready() -> void:
	_help_desk_interactable.visible = false
	_help_desk_interactable.interacted.connect(_on_help_desk_interactable_interacted)

func _process(_delta: float) -> void:
	_process_queued_customers()

func _process_queued_customers() -> void:
	if _queued_desk_customers.size() > 0:
		if _desk_customer != null:
			return
		var new_current_customer: Customer = _queued_desk_customers.pop_front()
		_customer_queue_update_visuals()
		_set_customer(new_current_customer)

func _customer_queue_update_visuals() -> void:
	var i: int = 0
	for queued_customer in _queued_desk_customers:
		var ratio_along_queue: float = (i as float) / Stats.current.max_customers_queued_per_machine
		var queue_global_position: Vector3 = _start_of_customer_queue_marker.global_position.lerp(_end_of_customer_queue_marker.global_position, ratio_along_queue)
		queued_customer.move_to(queue_global_position)
		i += 1

func customer_queue_size() -> int:
	return _queued_desk_customers.size()

func add_customer_to_queue(new_customer: Customer) -> void:
	_queued_desk_customers.append(new_customer)
	_customer_queue_update_visuals()

func has_active_customers() -> bool:
	return _queued_desk_customers.size() > 0 or _desk_customer != null

func _set_customer(new_customer: Customer) -> void:
	_desk_customer = new_customer
	if _desk_customer != null:
		_desk_customer.wait_timed_out.connect(_on_customer_wait_timed_out)
		await _desk_customer.move_to(_spot_for_customer.global_position)
		new_desk_customer_arrived.emit()
		
		# Set unlimited for tutorial day
		if Global.day == 0:
			pass
		else:
			_desk_customer.timer.wait_time = Stats.current.customer_wait_time_help_desk_each_day[Global.day]
			_desk_customer.timer.start()
			_desk_customer.waiting_indicator.show()
		bell_sound.play()
		_help_desk_interactable.visible = true
	else:
		_help_desk_interactable.visible = false

func _on_customer_wait_timed_out(timed_out_customer: Customer) -> void:
	timed_out_customer.wait_timed_out.disconnect(_on_customer_wait_timed_out)
	if _desk_customer == timed_out_customer:
		Global.score_update_message = "customer didn't get help"
		Global.employee_rating -= Stats.current.help_desk_customer_timed_out_rating_loss_each_day[Global.day]
		_desk_customer.timer.stop()
		_desk_customer.leave_store()
		_set_customer(null)

func _on_help_desk_interactable_interacted() -> void:
	if _desk_customer == null:
		return
	
	Global.active_help_desk_customer = _desk_customer
	Global.active_help_desk_customer.wait_timed_out.connect(_on_customer_wait_timed_out_during_minigame)
	
	Events.minigame_end.connect(_on_minigame_end)
	Events.minigame_cancelled.connect(_on_minigame_cancelled)

	Events.minigame_active.emit("Typing")

func _on_minigame_end() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)
	
	Global.score_update_message = "customer placated"
	Global.employee_rating += Stats.current.help_desk_customer_success_rating_gain_each_day[Global.day]
	Global.active_help_desk_customer.timer.stop()
	Global.active_help_desk_customer.leave_store()
	_set_customer(null)

func _on_minigame_cancelled() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)

	Global.active_help_desk_customer.wait_timed_out.disconnect(_on_customer_wait_timed_out_during_minigame)

func _on_customer_wait_timed_out_during_minigame(timed_out_customer: Customer) -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)
	
	Events.force_close_minigame.emit()
