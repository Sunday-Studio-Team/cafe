extends Node3D

@export var plane: MeshInstance3D

var material : ShaderMaterial = null;

func _ready() -> void:
	material = plane.get_surface_override_material(0);


func _process(delta: float) -> void:
	if (!Global.shift_started):
		material.set_shader_parameter("progress", 0.0);
	else:
		material.set_shader_parameter("progress", Global.shift_progress_ratio)
