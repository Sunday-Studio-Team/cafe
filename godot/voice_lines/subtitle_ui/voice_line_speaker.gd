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

var speaker_color: Color:
	get:
		match speaker_enum:
			SpeakerEnum.SATO:
				# Blue
				return Color.from_string("89a4d7", Color.BLACK)
			SpeakerEnum.TIPPY:
				# Green
				return Color.from_string("4fa468", Color.BLACK)
			_:
				return Color.WHITE
