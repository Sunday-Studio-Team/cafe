class_name VoiceLinePlayer
extends Node3D

signal finished_playing_voice_line(voice_line: VoiceLine)

enum PlayerMode {
	NON_DIRECTIONAL,
	THREE_D,
}

@export var _player_mode: PlayerMode
@export_group("Player Mode: Non-Directional")
@export var _audio_stream_player: AudioStreamPlayer
@export_group("Player Mode: 3D")
@export var tippy_loudspeaker_model: TippyLoudspeakerModel
@export var _audio_stream_player_3d: AudioStreamPlayer3D

var _active_voice_line: VoiceLine


func play_voice_line(voice_line: VoiceLine) -> void:
	_active_voice_line = voice_line
	if _active_voice_line.audio_stream == null:
		var duration: float = VoiceLineSystem.calculate_missing_audio_stream_caption_duration(
			_active_voice_line
		)
		print(
			"Voice line \"%s\" has no audio stream! Playing silently for %s seconds."
			% [_active_voice_line.voice_line_id, duration]
		)
		await get_tree().create_timer(duration, false).timeout
	else:
		match _player_mode:
			PlayerMode.NON_DIRECTIONAL:
				_audio_stream_player.stream = _active_voice_line.audio_stream
				_audio_stream_player.play()
				await _audio_stream_player.finished
			PlayerMode.THREE_D:
				_audio_stream_player_3d.stream = _active_voice_line.audio_stream
				_audio_stream_player_3d.play()
				var _playing_animation := tippy_loudspeaker_model.animation_player.get_animation("playing")
				_playing_animation.loop_mode = Animation.LOOP_LINEAR
				tippy_loudspeaker_model.animation_player.play("playing")
				await _audio_stream_player_3d.finished
				# i think if we just stop() the player itll jump back to its reset position
				# so this is smoother
				# (ideally we could get rid of the delay where it waits for the end of the
				# animation tho . . .)
				_playing_animation.loop_mode = Animation.LOOP_NONE
			_:
				printerr("Unknown VoiceLinePlayer.PlayerMode.")
				return
	if _active_voice_line != null:
		_active_voice_line = null
	finished_playing_voice_line.emit(voice_line)


func get_playing_voice_line() -> VoiceLine:
	return _active_voice_line


func interrupt_voice_line() -> void:
	match _player_mode:
		PlayerMode.NON_DIRECTIONAL:
			if _active_voice_line != null:
				finished_playing_voice_line.emit(_active_voice_line)
				_audio_stream_player.stop()
				_active_voice_line = null
		PlayerMode.THREE_D:
			if _active_voice_line != null:
				finished_playing_voice_line.emit(_active_voice_line)
				_audio_stream_player_3d.stop()
				_active_voice_line = null
		_:
			printerr("Unknown VoiceLinePlayer.PlayerMode.")
			return


func _physics_process(delta: float) -> void:
	# for some reason this is running @ the start before it has this reference so
	if tippy_loudspeaker_model != null and tippy_loudspeaker_model.sound_ring_particles != null:
		tippy_loudspeaker_model.sound_ring_particles.emitting = get_playing_voice_line() != null
