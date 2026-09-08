class_name VoiceLineLocationPlayer
extends Node3D

signal finished_playing_voice_line(voice_line: VoiceLine)

@export var _audio_stream_player_3d: AudioStreamPlayer3D

var _active_voice_line: VoiceLine

func play_voice_line(voice_line: VoiceLine) -> void:
	if voice_line.audio_stream == null:
		printerr("Missing audio stream!")
		return
	_audio_stream_player_3d.stream = voice_line.audio_stream
	_active_voice_line = voice_line
	_audio_stream_player_3d.play()
	await _audio_stream_player_3d.finished
	finished_playing_voice_line.emit(voice_line)
	_active_voice_line = null

func interrupt_voice_line() -> void:
	if _audio_stream_player_3d.playing and _active_voice_line != null:
		finished_playing_voice_line.emit(_active_voice_line)
	_audio_stream_player_3d.stop()
	destroy()

func destroy() -> void:
	queue_free()
