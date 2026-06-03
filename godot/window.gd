extends Node3D

@export var customer_queue: CustomerQueue
@export var bell_sound: AudioStreamPlayer3D
@export var customer_complained_indicator: Label3D


func _ready() -> void:
	Events.customer_approached_window.connect(_on_customer_approached_window)
	customer_queue.customer_added.connect(
		func():
			bell_sound.play()
			await get_tree().create_timer(0.5, false).timeout
			Global.score_update_message = "customer complained"
			Global.customer_score -= 1
			customer_complained_indicator.show()
			await get_tree().create_timer(1, false).timeout
			customer_complained_indicator.hide()
	)


func _on_customer_approached_window(customer: Customer) -> void:
	customer_queue.add_customer(customer)
