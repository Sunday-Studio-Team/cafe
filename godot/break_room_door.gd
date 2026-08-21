extends Node3D

@export var door_physics_body: PhysicsBody3D
@export var door_open_angle: float = 105.0
@export var open_sound: AudioStreamPlayer3D
@export var close_sound: AudioStreamPlayer3D
@export var exited_break_room_detection_area: PlayerDetectionArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_tween().tween_property(door_physics_body, "rotation_degrees:y", door_open_angle, 0.5)
	open_sound.play()
	Events.shift_started.connect(_on_shift_started)

func _on_shift_started():
	exited_break_room_detection_area.player_entered_area.connect(
		func(_detection_area: PlayerDetectionArea):
			_on_player_entered_detection_area(),
		CONNECT_ONE_SHOT,
	)


func _on_player_entered_detection_area() -> void:
	create_tween().tween_property(door_physics_body, "rotation_degrees:y", 0, 0.5)
	close_sound.play()
