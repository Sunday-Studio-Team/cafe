class_name VoiceLineLocationPlayer
extends Node3D

signal finished_playing_voice_line(voice_line: VoiceLine)

@export var _audio_stream_player_3d: AudioStreamPlayer3D

var _active_voice_line: VoiceLine

func play_voice_line(voice_line: VoiceLine) -> void:
	if voice_line.audio_stream == null:
		var duration: float = VoiceLineSystem.calculate_missing_audio_stream_caption_duration(voice_line)
		print("Voice line \"%s\" has no audio stream! Playing silently for %s seconds." % [voice_line.voice_line_id, duration])
		await get_tree().create_timer(duration, false).timeout
	else:
		_audio_stream_player_3d.stream = voice_line.audio_stream
		_active_voice_line = voice_line
		_audio_stream_player_3d.play()
		await _audio_stream_player_3d.finished
		_active_voice_line = null
	finished_playing_voice_line.emit(voice_line)

func get_playing_voice_line() -> VoiceLine:
	return _active_voice_line

func interrupt_voice_line() -> void:
	if _audio_stream_player_3d.playing and _active_voice_line != null:
		finished_playing_voice_line.emit(_active_voice_line)
	_audio_stream_player_3d.stop()
	destroy()

func destroy() -> void:
	queue_free()
