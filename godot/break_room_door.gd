extends Node3D

@export var door_physics_body: PhysicsBody3D
@export var door_open_angle: float = 105.0
@export var open_sound: AudioStreamPlayer3D
@export var close_sound: AudioStreamPlayer3D
@export var exited_break_room_detection_area: PlayerDetectionArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_door()
	Events.tippy_boss_kidnapped_player.connect(close_door)
	Events.tippy_boss_released_player.connect(
		func():
			open_door()
			close_door_when_player_exits(),
	)


func open_door() -> void:
	open_sound.play()
	create_tween().tween_property(door_physics_body, "rotation_degrees:y", door_open_angle, 0.5)


func close_door() -> void:
	create_tween().tween_property(door_physics_body, "rotation_degrees:y", 0, 0.5)
	close_sound.play()


func close_door_when_player_exits():
	exited_break_room_detection_area.player_entered_area.connect(
		func(_detection_area: PlayerDetectionArea):
			close_door()
			Events.player_left_office.emit(),
		CONNECT_ONE_SHOT,
	)
