extends Node3D

@export var ray: RayCast3D
@export var rotation_amount: float = 90
@export var rotation_time: float = 3
@export var timer: Timer

var rotate_tween: Tween


func _ready() -> void:
	var original_rotation = rotation_degrees

	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y + rotation_amount, rotation_time)
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y - rotation_amount, rotation_time)


func _physics_process(_delta: float) -> void:
	var collider = ray.get_collider()
	if collider == Global.player and timer.is_stopped():
		if Input.is_action_pressed("sprint"):
			Events.player_caught_sprinting.emit()
			timer.start()
			Global.customer_score -= Global.penalty_for_sprinting
		elif Input.is_action_pressed("interact") and Global.hovered_interactable.display_name.contains("remake drink"):
			Events.player_caught_remaking.emit()
			timer.start()
			Global.customer_score -= Global.penalty_for_remaking_drink
