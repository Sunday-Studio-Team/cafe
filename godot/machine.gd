class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer

var occupied := false:
	set(value):
		occupied = value
		if not occupied:
			customer = null
			return
		await get_tree().create_timer(randf_range(1, 3), false).timeout
		start_order()
var customer: Customer


func _ready() -> void:
	timer.timeout.connect(_on_order_finished)
	progress_bar.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100


func start_order() -> void:
	timer.start()
	progress_bar.show()


func _on_order_finished() -> void:
	progress_bar.hide()
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	Events.customer_left_machine.emit(customer)
	occupied = false

	print("order finished")
