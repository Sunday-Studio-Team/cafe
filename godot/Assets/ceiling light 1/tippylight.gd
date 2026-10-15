extends Node3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(randf_range(0,1)).timeout
	process_mode = PROCESS_MODE_INHERIT


func _physics_process(_delta: float) -> void:
	var degrees_to_rotate_each_frame: float = 1 + abs(sin(Engine.get_physics_frames() / 250.0))
	rotation_degrees.y += degrees_to_rotate_each_frame
