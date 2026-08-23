class_name VoiceLineNoLocationPlayer
extends Node

signal finished_playing_voice_line(voice_line: VoiceLine)

@export var _audio_stream_player_3ds: Array[AudioStreamPlayer3D]

var _playing_voice_line: VoiceLine

func play_voice_line(voice_line: VoiceLine) -> void:
	# Interrupt existing voice line
	if _playing_voice_line:
		for player in _audio_stream_player_3ds:
			player.stop()
		await finished_playing_voice_line
	
	if voice_line.audio_stream == null:
		printerr("Missing audio stream!")
		return
	for player in _audio_stream_player_3ds:
		player.stream = voice_line.audio_stream
		player.play()
	_playing_voice_line = voice_line
	var all_done_playing: bool = false
	while !all_done_playing:
		var done_players_count: int = 0
		for player in _audio_stream_player_3ds:
			if !player.playing:
				done_players_count += 1
		if done_players_count != _audio_stream_player_3ds.size():
			await get_tree().process_frame
		else:
			all_done_playing = true
	_playing_voice_line = null
	finished_playing_voice_line.emit(voice_line)

func get_playing_voice_line() -> VoiceLine:
	return _playing_voice_line
