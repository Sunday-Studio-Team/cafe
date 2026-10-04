extends AudioStreamPlayer3D

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
