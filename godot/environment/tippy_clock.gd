extends Node3D

@export var plane: MeshInstance3D
@export var tick_sound: AudioStreamPlayer3D

var material: ShaderMaterial = null;


func _ready() -> void:
	material = plane.get_surface_override_material(0);

	Events.shift_started.connect(
			func() -> void:
				tick_sound.play()
	)
	Events.shift_end_sequence_started.connect(
			func() -> void:
				tick_sound.stop()
	)


func _physics_process(_delta: float) -> void:
	if (!Global.shift_started):
		material.set_shader_parameter("progress", 0.0);
	else:
		material.set_shader_parameter("progress", Global.shift_progress_ratio)
