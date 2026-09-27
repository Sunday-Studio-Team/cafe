extends Node3D


func _physics_process(delta: float) -> void:
	var degrees_to_rotate_each_frame: float = 1 + abs(sin(Engine.get_physics_frames() / 250.0))
	rotation_degrees.y += degrees_to_rotate_each_frame