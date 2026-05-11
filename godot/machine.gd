class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var current_order_indicator: Label3D
@export var final_order_indicator: Label3D

var occupied := false:
	set(value):
		occupied = value
		if not occupied:
			customer = null
			return
		await get_tree().create_timer(randf_range(1, 3), false).timeout
		start_order()
var customer: Customer
var customers_order: Drink
var completed_order: Drink


func _ready() -> void:
	timer.timeout.connect(_on_order_finished)
	progress_bar.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100


func start_order() -> void:
	timer.start()
	customers_order = Global.drinks.pick_random()
	current_order_indicator.text = customers_order.drink_name
	progress_bar.show()


func score_drink() -> void:
	var score := 0
	if completed_order.main_ingredient == customers_order.main_ingredient:
		score += 1
	else:
		score -= 1
	if completed_order.liquid == customers_order.liquid:
		score += 1
	else:
		score -= 1
	if completed_order.extra == customers_order.extra:
		score += 1
	else:
		score -= 1

	print("adding ", score, " to score")
	Global.score += score
	print("score is now ", Global.score)


func _on_order_finished() -> void:
	progress_bar.hide()
	completed_order = Global.drinks.pick_random()
	final_order_indicator.text = completed_order.drink_name
	score_drink()

	await get_tree().create_timer(randf_range(1, 2), false).timeout
	Events.customer_left_machine.emit(customer)
	occupied = false

	print("order finished")
