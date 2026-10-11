class_name VoiceLineSpeaker
extends Resource

enum SpeakerEnum {
	SATO,
	TIPPY,
}

@export var speaker_enum: SpeakerEnum

var speaker_name: String:
	get:
		match speaker_enum:
			SpeakerEnum.SATO:
				return "Sato" 
			SpeakerEnum.TIPPY:
				return "Tippy" 
			_:
				return "Unset Speaker" 
