extends Node2D

const MOVE_SPEED := 6
const BEANS_TO_SPAWN := 5
const LEFT_RIGHT_FORCE := 250

@export var cup: CharacterBody2D
@export var bean_scene: PackedScene
@export var pour_point: Marker2D
@export var bean_spawn_timer: Timer
@export var cup_area: Area2D
@export var cup_boundaries: Area2D
@export var meter: ProgressBar
@export var bag: Node2D
@export var bean_hit_glasss_sound: AudioStreamPlayer2D
@export var bag_shake_sound: AudioStreamPlayer2D
@export var gain_score_sound: AudioStreamPlayer

var beans_in_cup := 0
var beans_spawned := 0
var bag_shake_tween: Tween
var collected_beans: Array[PhysicsBody2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bean_spawn_timer.timeout.connect(spawn_bean)
	cup_area.body_entered.connect(catch_bean)
	cup_area.body_exited.connect(spill_bean)

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	bag_shake_tween = create_tween().set_loops()
	bag_shake_tween.tween_property(bag, "position:y", bag.position.y + 30, 0.2)
	bag_shake_tween.tween_property(bag, "position:y", bag.position.y - 30, 0.2)

	cup_boundaries.body_entered.connect(
		func(body):
			if body.is_in_group("beans"):
				bean_hit_glasss_sound.play()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var left_right_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").x
	cup.position.x += left_right_input * MOVE_SPEED
	cup.position.x = clamp(cup.position.x, 600, 1300)
	cup.rotation_degrees = lerp(
		cup.rotation_degrees,
		left_right_input * 7,
		delta * 5,
	)

	meter.value = float(beans_in_cup) / float(BEANS_TO_SPAWN)


func spawn_bean() -> void:
	if beans_spawned < BEANS_TO_SPAWN:
		var bean: RigidBody2D = bean_scene.instantiate()
		bean.global_position = pour_point.global_position
		bean.add_to_group("beans")
		add_child(bean)
		bean.apply_impulse(Vector2(randf_range(-LEFT_RIGHT_FORCE, LEFT_RIGHT_FORCE), 0))
		bean.rotation_degrees = randf_range(0, 360)
		beans_spawned += 1
	else:
		Global.refill_minigame_accuracy = meter.value
		bag_shake_tween.kill()
		bag_shake_sound.stop()
		await get_tree().create_timer(1.5, false).timeout
		Events.emit_signal("minigame_end")


func catch_bean(bean: PhysicsBody2D) -> void:
	if not collected_beans.has(bean) and bean.is_in_group("beans"):
		beans_in_cup += 1
		gain_score_sound.play()
		gain_score_sound.pitch_scale += 0.05
		collected_beans.append(bean)


func spill_bean(bean: PhysicsBody2D) -> void:
	if collected_beans.has(bean):
		collected_beans.erase(bean)
		beans_in_cup -= 1
