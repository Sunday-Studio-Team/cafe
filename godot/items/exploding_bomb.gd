class_name ExplodingBomb
extends RigidBody3D

@export var explode_timer: Timer
@export var range_indicator: MeshInstance3D
@export var timer_progress_indicator: MeshInstance3D
@export var danger_light: OmniLight3D
@export var drop_impact_sound: AudioStreamPlayer3D
@export var ticking_siren_sound: AudioStreamPlayer3D
@export var ticking_timer: Timer
@export var explode_sound: AudioStreamPlayer3D
@export var model: Node3D
@export var explosion_particles: GPUParticles3D
@export var meow_sound: AudioStreamPlayer3D

var player: Player

@onready var starting_light_energy := danger_light.light_energy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	explode_timer.timeout.connect(explode)
	ticking_timer.timeout.connect(
			func():
				ticking_siren_sound.play()
				var new_scale_for_progress_indicator: Vector3 = timer_progress_indicator.scale + (Vector3.ONE / (explode_timer.wait_time - 1))
				var t := create_tween().set_trans(Tween.TRANS_SPRING)
				await t.tween_property(timer_progress_indicator, "scale", new_scale_for_progress_indicator,
						0.1).finished
				if timer_progress_indicator.scale >= Vector3.ONE:
					ticking_siren_sound.volume_db = -100
					var indicators_shrink_tween := create_tween().set_parallel()
					indicators_shrink_tween.tween_property(range_indicator, "scale", Vector3.ZERO, 0.25)
					indicators_shrink_tween.tween_property(timer_progress_indicator, "scale", Vector3.ZERO, 0.25)
					ticking_timer.stop()
					meow_sound.play()

	)

	player = Global.player

	range_indicator.scale = Vector3.ZERO
	timer_progress_indicator.scale = Vector3.ZERO
	danger_light.light_energy = 0


func _on_body_entered(body: PhysicsBody3D) -> void:
	# if we hit something solid like a wall, we stick to it
	if body is StaticBody3D:
		gravity_scale = 0
		linear_damp = 5

		explode_timer.start()

		drop_impact_sound.play()
		ticking_siren_sound.play()
		ticking_timer.start()

		create_tween().tween_property(range_indicator, "scale", Vector3.ONE, 0.5)
		var bomb_light_tween := create_tween().set_loops()
		bomb_light_tween.tween_property(danger_light, "light_energy", starting_light_energy, 0.5)
		bomb_light_tween.tween_property(danger_light, "light_energy", 0, 0.5)


func explode() -> void:
	explode_sound.play()
	explosion_particles.emitting = true

	var player_grounded_position: Vector3 = player.global_position
	player_grounded_position.y = 0
	var bomb_grounded_position: Vector3 = global_position
	bomb_grounded_position.y = 0
	var player_distance_from_bomb: float = player_grounded_position.distance_squared_to(bomb_grounded_position)

	const MIN_FORCE := 1.0
	const MAX_FORCE := 30.0

	var bomb_force_magnitude: float = remap(player_distance_from_bomb, 1, 4, MAX_FORCE, MIN_FORCE)
	bomb_force_magnitude = clampf(bomb_force_magnitude, MIN_FORCE, MAX_FORCE)

	var bomb_force: Vector3 = bomb_force_magnitude * bomb_grounded_position.direction_to(player_grounded_position)
	bomb_force.y += bomb_force_magnitude * 0.2

	player.velocity += bomb_force

	model.hide()
	danger_light.hide()
	var range_indicator_tween := create_tween().set_parallel()
	range_indicator_tween.tween_property(range_indicator, "scale", Vector3.ONE * 5, 0.5)
	range_indicator_tween.tween_property(range_indicator, "transparency", 1, 0.5)

	await explode_sound.finished
	queue_free()
	
