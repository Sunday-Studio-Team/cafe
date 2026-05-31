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
		timer.start()
		Global.customer_score -= 5
