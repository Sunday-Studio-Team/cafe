extends AudioStreamPlayer3D

## tracks for the start and during shift
# NOTE: it seems like pitch scale doesnt work on AudioStreamPlaylists so we're recreating that
# 		functionality manually here instead
@export var shift_tracks: Array[AudioStream]
@export var shift_ending_music: AudioStream
# NOTE: just playing thru the music once seems fine for now but we can loop this infinitely if needed
@export var shift_ending_music_outro_loop: AudioStream
@export var loudspeaker_model: TippyLoudspeakerModel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.shift_end_sequence_started.connect(
		func() -> void:
			stream = shift_ending_music
			play()
			autoplay = false,
	)

	loudspeaker_model.animation_player.play("playing")
	loudspeaker_model.sound_ring_particles.emitting = true

	finished.connect(
		func() -> void:
			if not Global.main_scene.closing_time:
				play_random_shift_track()
			)

	# Don't play music when day 5 starts, wait for shift start signal
	if Global.day == 5:
		Events.shift_start_requested.connect(
			func() -> void:
				play_random_shift_track(true),
			CONNECT_ONE_SHOT
		)
	else:
		play_random_shift_track()


func play_random_shift_track(with_creepy_startup: bool = false) -> void:
	stream = shift_tracks.pick_random()
	play()

	if with_creepy_startup:
		create_tween().tween_property(self, "pitch_scale", 1, 3).from(0)
