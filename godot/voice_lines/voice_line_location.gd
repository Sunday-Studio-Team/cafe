class_name VoiceLineLocation
extends Node3D

@export var _voice_line_location_player_packed_scene: PackedScene

func internal_setup_voice_line_at_location(voice_line: VoiceLine) -> VoiceLineLocationPlayer:
	var voice_line_location_player: VoiceLineLocationPlayer = _voice_line_location_player_packed_scene.instantiate()
	add_child(voice_line_location_player)
	return voice_line_location_player
