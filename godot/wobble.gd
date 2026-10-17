extends MeshInstance3D

@export var shader_material: ShaderMaterial
@export var turbulence_multiplier: float = 0.002
@export var smoothness: float = 10.0

var last_position: Vector3
var smooth_speed: float = 0.0

func _ready() -> void:
	last_position = global_position

func _process(delta: float) -> void:
	if delta == 0.0:
		return
		
	var distance_moved = global_position.distance_to(last_position)
	var speed = distance_moved / delta
	last_position = global_position 
	
	var weight = clamp(delta * smoothness, 0.0, 1.0)
	smooth_speed = lerp(smooth_speed, speed, weight)

	if shader_material:
		var target_turbulence = smooth_speed * turbulence_multiplier
		shader_material.set_shader_parameter("turbulence_strength", target_turbulence)
