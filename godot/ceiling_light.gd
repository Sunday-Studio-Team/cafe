extends Node3D

@export var area_light: AreaLight3D
@export var shared_light_surface_material: StandardMaterial3D
@export var noise_texture: NoiseTexture2D
@export var light_surface_meshes: Array[MeshInstance3D]

var our_light_surface_material: StandardMaterial3D

@onready var noise_x_coord := randf()


func _ready() -> void:
	our_light_surface_material = shared_light_surface_material.duplicate()
	for mesh in light_surface_meshes:
		mesh.set_surface_override_material(0, our_light_surface_material)


func _process(delta: float) -> void:
	var noise_sample: float = abs(noise_texture.noise.get_noise_1d(noise_x_coord))

	noise_x_coord += delta / 5

	area_light.light_energy = remap(noise_sample, 0, 0.25, 0, 25)
	our_light_surface_material.emission_energy_multiplier = remap(noise_sample, 0, 0.25, 0, 2)
