class_name ExplodingBomb
extends RigidBody3D

@export var explode_timer: Timer
@export var time_til_explosion_label: Label3D

var player: Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	explode_timer.timeout.connect(explode)

	player = Global.player

	explode_timer.start()


func _physics_process(_delta: float) -> void:
	time_til_explosion_label.text = str(ceil(explode_timer.time_left))
	time_til_explosion_label.global_position = global_position + Vector3(0, 1, 0)


func _on_body_entered(body: PhysicsBody3D) -> void:
	# if we hit something solid like a wall, we stick to it
	if body is StaticBody3D:
		gravity_scale = 0
		linear_damp = 5

		time_til_explosion_label.show()


func explode() -> void:
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
	bomb_force.y += 1

	player.velocity += bomb_force

	await get_tree().create_timer(0.15, false).timeout
	queue_free()
	
