class_name VoiceLineLocationPlayer
extends Node3D

signal finished_playing_voice_line(voice_line: VoiceLine)

@export var _audio_stream_player_3d: AudioStreamPlayer3D

func play_voice_line(voice_line: VoiceLine) -> void:
	if voice_line.audio_stream == null:
		printerr("Missing audio stream!")
		return
	_audio_stream_player_3d.stream = voice_line.audio_stream
	await _audio_stream_player_3d.finished
	finished_playing_voice_line.emit(voice_line)

func interrupt_voice_line() -> void:
	_audio_stream_player_3d.stop()
