extends Node3D

@export var open_offset := Vector3(2.0, 0.0, 0.0)
@export var move_time := 0.8

@onready var door_mesh: Node3D = $"Sliding Door"
@onready var trigger: Area3D = $"Proximity Trigger"

var closed_position: Vector3
var active_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	closed_position = door_mesh.position

	trigger.body_entered.connect(_on_trigger_body_entered)
	trigger.body_exited.connect(_on_trigger_body_exited)

func _on_trigger_body_entered(_body: Node3D) -> void:
	open_door()

func _on_trigger_body_exited(_body: Node3D) -> void:
	close_door()

func open_door() -> void:
	move_door_to(closed_position + open_offset)

func close_door() -> void:
	move_door_to(closed_position)

## Moves the door from its current local position to [param target_position].
func move_door_to(target_position: Vector3) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)

	active_tween.tween_property(
		door_mesh,
		"position",
		target_position,
		move_time
	)
