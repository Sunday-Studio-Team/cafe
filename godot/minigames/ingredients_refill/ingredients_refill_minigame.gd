extends Node2D

const MOVE_SPEED := 5

@export var cup: CharacterBody2D
@export var bean_scene: PackedScene
@export var pour_point: Marker2D
@export var bean_spawn_timer: Timer
@export var game_timer: Timer
@export var catch_point: Area2D

var beans_in_cup := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bean_spawn_timer.timeout.connect(spawn_bean)
	game_timer.timeout.connect(_on_time_up)
	catch_point.body_entered.connect(catch_bean)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var left_right_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").x
	cup.position.x += left_right_input * MOVE_SPEED


func spawn_bean() -> void:
	var bean: RigidBody2D = bean_scene.instantiate()
	pour_point.add_child(bean)
	bean.apply_impulse(Vector2(randf_range(-200, 200), 0))
	bean.rotation_degrees = randf_range(0, 360)


func catch_bean(bean: RigidBody2D) -> void:
	bean.queue_free()
	beans_in_cup += 1


func _on_time_up() -> void:
	pass
