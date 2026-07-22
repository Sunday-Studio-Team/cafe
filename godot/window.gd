extends Node3D

@export var customer_queue: CustomerQueue
@export var bell_sound: AudioStreamPlayer3D
@export var customer_alert_indicator: Label3D

func _ready() -> void:
	Events.customer_approached_window.connect(_on_customer_approached_window)
	customer_queue.customer_added.connect(
		func():
			bell_sound.play()
	)


func _on_customer_approached_window(customer: Customer) -> void:
	customer_queue.add_customer(customer)
