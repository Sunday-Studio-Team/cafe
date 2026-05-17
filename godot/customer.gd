class_name Customer
extends Node3D

@export var waiting_indicator: Sprite3D
@export var waiting_bar: TextureProgressBar
@export var timer: Timer
@export var time_bonus_label: Label3D

var bonus_points_for_time: int


func _ready() -> void:
	Events.order_completed.connect(_on_order_completed)
	Events.order_approved.connect(_on_order_approved)
	Events.customer_left_machine.connect(_on_customer_left_machine)
	# NOTE: not actually sure what this true argument does here lol
	add_to_group("customers", true)
	print("spawned a customer")

	waiting_indicator.hide()


func _physics_process(_delta: float) -> void:
	waiting_bar.value = timer.time_left / timer.wait_time * 100

	var timer_progress_ratio: float = 1 - timer.time_left / timer.wait_time
	if timer_progress_ratio < 0.333:
		waiting_indicator.modulate = Color.GREEN
		bonus_points_for_time = 1
	elif timer_progress_ratio < 0.666:
		waiting_indicator.modulate = Color.ORANGE
		bonus_points_for_time = 0
	else:
		waiting_indicator.modulate = Color.RED
		bonus_points_for_time = -1


func _exit_tree() -> void:
	print("customer despawned")


func _on_order_completed(customer: Customer) -> void:
	if customer != self:
		return
	timer.start()
	waiting_indicator.show()


func _on_order_approved(customer: Customer) -> void:
	if customer != self:
		return

	Global.score += bonus_points_for_time

	match bonus_points_for_time:
		1:
			time_bonus_label.modulate = Color.GREEN
			time_bonus_label.text = "time bonus: +1"
		-1:
			time_bonus_label.modulate = Color.RED
			time_bonus_label.text = "time penalty: -1"


func _on_customer_left_machine(customer: Customer) -> void:
	if customer != self:
		return

	waiting_indicator.hide()
	time_bonus_label.hide()
	global_transform = Global.customer_leaving_spot.global_transform
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	queue_free()
