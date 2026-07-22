extends Node3D

enum State {
	PRE_SHIFT_START,
	SHIFT_STARTED,
	DOOR_RECLOSED,
}

@export var open_sound: AudioStreamPlayer3D
@export var close_sound: AudioStreamPlayer3D
@export var animation_player: AnimationPlayer
@export var open_door_animation_name: String
@export var close_door_animation_name: String
@export var exited_break_room_detection_area: PlayerDetectionArea

var _state: State


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state = State.PRE_SHIFT_START
	Events.shift_started.connect(_on_shift_started)


func _on_shift_started() -> void:
	if _state != State.PRE_SHIFT_START:
		return
	_state = State.SHIFT_STARTED
	open_sound.play()
	animation_player.play(open_door_animation_name)
	exited_break_room_detection_area.player_entered_area.connect(_on_player_entered_detection_area)


func _on_player_entered_detection_area(detection_area: PlayerDetectionArea) -> void:
	if _state != State.SHIFT_STARTED:
		return
	exited_break_room_detection_area.player_entered_area.disconnect(_on_player_entered_detection_area)
	_state = State.DOOR_RECLOSED
	animation_player.play(close_door_animation_name)
	close_sound.play()
