extends Node2D

const MOVE_SPEED := 5
const BEANS_TO_SPAWN := 10

@export var cup: CharacterBody2D
@export var bean_scene: PackedScene
@export var pour_point: Marker2D
@export var bean_spawn_timer: Timer
@export var catch_point: Area2D
@export var meter: ProgressBar
@export var bag_sprite: Sprite2D

var beans_in_cup := 0
var beans_spawned := 0
var bag_shake_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bean_spawn_timer.timeout.connect(spawn_bean)
	catch_point.body_entered.connect(catch_bean)

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	bag_shake_tween = create_tween().set_loops()
	bag_shake_tween.tween_property(bag_sprite, "position:y", bag_sprite.position.y + 30, 0.2)
	bag_shake_tween.tween_property(bag_sprite, "position:y", bag_sprite.position.y - 30, 0.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var left_right_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").x
	cup.position.x += left_right_input * MOVE_SPEED
	cup.position.x = clamp(cup.position.x, 600, 1300)

	meter.value = float(beans_in_cup) / float(BEANS_TO_SPAWN)


func spawn_bean() -> void:
	if beans_spawned < BEANS_TO_SPAWN:
		var bean: RigidBody2D = bean_scene.instantiate()
		pour_point.add_child(bean)
		bean.apply_impulse(Vector2(randf_range(-200, 200), 0))
		bean.rotation_degrees = randf_range(0, 360)
		beans_spawned += 1
	else:
		Global.refill_minigame_accuracy = meter.value
		bag_shake_tween.kill()
		await get_tree().create_timer(2, false).timeout
		Events.emit_signal("minigame_end")


func catch_bean(bean: RigidBody2D) -> void:
	bean.queue_free()
	beans_in_cup += 1
