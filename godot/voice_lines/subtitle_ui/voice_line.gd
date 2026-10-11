class_name VoiceLine
extends Resource

enum SpeakerEnum {
	TIPPY,
	SATO,
}

@export var voice_line_id: String
@export var audio_stream: AudioStream
@export var volume_linear: float = 1.0
@export var speaker: VoiceLineSpeaker
@export_multiline var subtitle_en: String
## Priority voice lines will play over and not be overridden by non-priority voice lines.
@export var is_priority: bool
