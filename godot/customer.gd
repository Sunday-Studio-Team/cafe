class_name Customer
extends Node3D

@export var body: Sprite3D
@export var waiting_indicator: Sprite3D
@export var waiting_bar: TextureProgressBar
@export var timer: Timer
@export var time_bonus_label: Label3D
@export_dir var sprites_folder: String

var desired_drink: Drink
var window_wait_time: float = 30
var orders_made: int = 0
var bonus_points_for_time: int
var at_window: bool = false
var percent_time_left: float = 100


func _ready() -> void:
	body.texture = Global.customer_sprites.pick_random()
	get_stats()
	timer.timeout.connect(_on_timer_timeout)
	Events.customer_started_order.connect(_on_order_started)
	Events.order_approved.connect(_on_order_approved)
	Events.customer_left_machine.connect(_on_customer_left_machine)
	# NOTE: not actually sure what this true argument does here lol
	add_to_group("customers", true)

	desired_drink = Global.drinks.pick_random()


func _physics_process(_delta: float) -> void:
	# uncomment to show time above customer head
	#waiting_indicator.visible = not timer.is_stopped()

	if not timer.is_stopped():
		percent_time_left = timer.time_left / timer.wait_time * 100

	if percent_time_left >= 66:
		waiting_indicator.modulate = Color.GREEN
		bonus_points_for_time = 1
	elif percent_time_left >= 33:
		waiting_indicator.modulate = Color.ORANGE
		bonus_points_for_time = 0
	else:
		waiting_indicator.modulate = Color.RED
		bonus_points_for_time = -1

	waiting_bar.value = percent_time_left


func get_stats():
	timer.wait_time = Stats.current.customer_wait_time_machine


func leave_store() -> void:
	waiting_indicator.hide()
	global_transform = Global.customer_leaving_spot.global_transform
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	queue_free()


func _on_timer_timeout() -> void:
	if not at_window:
		Events.customer_approached_window.emit(self)


func _on_order_started(customer: Customer) -> void:
	if customer != self or orders_made > 0:
		return
	await get_tree().process_frame
	timer.start()
	orders_made += 1


func _on_order_approved(customer: Customer) -> void:
	if customer != self:
		return

	timer.stop()

	await get_tree().create_timer(1, false).timeout
	if bonus_points_for_time > 0:
		Global.score_update_message = "bonus for time"
	else:
		Global.score_update_message = "penalty for time"
	Global.employee_rating += bonus_points_for_time


func _on_customer_left_machine(customer: Customer, drink_score) -> void:
	if customer != self:
		return

	time_bonus_label.hide()
	if (drink_score > -3):
		leave_store()
	else:
		Events.customer_approached_window.emit(self)
