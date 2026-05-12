class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var current_order_indicator: Label3D
@export var final_order_indicator: Label3D
@export var score_label: Label3D
@export var accept_button: StaticBody3D

var occupied := false:
	set(value):
		occupied = value
		if not occupied:
			customer = null
			current_order_indicator.hide()
			final_order_indicator.hide()
			score_label.hide()
			return
		await get_tree().create_timer(randf_range(1, 3), false).timeout
		start_order()
var customer: Customer
var customers_order: Drink
var completed_order: Drink
var waiting_for_response: bool = false


func _ready() -> void:
	timer.timeout.connect(_on_order_finished)
	progress_bar.hide()
	score_label.hide()
	current_order_indicator.hide()
	final_order_indicator.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100


func start_order() -> void:
	timer.start()
	customers_order = Global.drinks.pick_random()
	current_order_indicator.text = "current order: " + customers_order.drink_name
	current_order_indicator.show()
	progress_bar.show()
	print("starting order")


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

	score_label.show()
	if score > 0:
		score_label.modulate = Color.GREEN_YELLOW
		score_label.text = "+ " + str(score)
	else:
		score_label.modulate = Color.RED
		score_label.text = str(score)


func _on_order_finished() -> void:
	progress_bar.hide()
	completed_order = Global.drinks.pick_random()
	final_order_indicator.text = "final order: " + completed_order.drink_name
	final_order_indicator.show()
	waiting_for_response = true


func _on_accept_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("Accept was clicked")
	if(!waiting_for_response or completed_order == null):
		return
	
	score_drink()
	waiting_for_response = false
	completed_order = null
	
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	Events.customer_left_machine.emit(customer)
	occupied = false
	
	print("order finished")


func _on_reject_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("Reject was clicked")
	if(!waiting_for_response):
		return
	final_order_indicator.text = "final order: "
	timer.start()
	progress_bar.show()
	print()
