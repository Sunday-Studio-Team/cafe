class_name VoiceLineNoLocationPlayer
extends Node

signal finished_playing_voice_line(voice_line: VoiceLine)
signal interrupted_playing_voice_line(voice_line: VoiceLine)

@export var _audio_stream_player_3ds: Array[AudioStreamPlayer3D]

var _playing_voice_line: VoiceLine


func play_voice_line(voice_line: VoiceLine) -> void:
	# Interrupt existing voice line
	await interrupt_current_voice_line()

	if voice_line.audio_stream == null:
		printerr("Missing audio stream!")
		return
	for player in _audio_stream_player_3ds:
		player.stream = voice_line.audio_stream
		await get_tree().create_timer(0.05, false).timeout
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


func interrupt_current_voice_line() -> void:
	if _playing_voice_line != null:
		for player in _audio_stream_player_3ds:
			player.stop()
		interrupted_playing_voice_line.emit(_playing_voice_line)
