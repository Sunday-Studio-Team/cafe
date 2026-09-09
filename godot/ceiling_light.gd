extends Node3D

@export var area_light: AreaLight3D
@export var spot_light: SpotLight3D
@export var shared_light_surface_material: StandardMaterial3D
@export var noise_texture: NoiseTexture2D
@export var light_surface_meshes: Array[MeshInstance3D]
@export var flicker_timer: Timer

var our_light_surface_material: StandardMaterial3D
var flickering := false

@onready var noise_x_coord := randf()

@onready var starting_area_light_energy := area_light.light_energy
@onready var starting_spot_light_energy := spot_light.light_energy
@onready var starting_material_emission := shared_light_surface_material.emission_energy_multiplier


func _ready() -> void:
	our_light_surface_material = shared_light_surface_material.duplicate()
	for mesh in light_surface_meshes:
		mesh.set_surface_override_material(0, our_light_surface_material)

	flicker_timer.wait_time = randf_range(5, 15)
	flicker_timer.start()
	flicker_timer.timeout.connect(
		func():
			flickering = !flickering
			if flickering:
				flicker_timer.wait_time = randf_range(0.1, 1)
			else:
				flicker_timer.wait_time = randf_range(5, 15)
			flicker_timer.start(),
	)


func _process(delta: float) -> void:
	if flickering:
		var noise_sample: float = abs(noise_texture.noise.get_noise_1d(noise_x_coord))

		noise_x_coord += delta

		area_light.light_energy = remap(noise_sample, 0, 0.25, 0, 25)
		spot_light.light_energy = remap(noise_sample, 0, 0.25, 0, 10)
		our_light_surface_material.emission_energy_multiplier = remap(noise_sample, 0, 0.25, 0, 2)
	else:
		area_light.light_energy = starting_area_light_energy
		spot_light.light_energy = starting_spot_light_energy
		our_light_surface_material.emission_energy_multiplier = starting_material_emission
