class_name SubtitleView
extends Control

@export var _subtitle_label: RichTextLabel

func setup(voice_line: VoiceLine) -> void:
	var output_string: String = ""
	
	if voice_line.speaker != null:
		var speaker_color: Color = voice_line.speaker.speaker_color
		var speaker_color_open_bbcode: String = "[color=%s]" % speaker_color.to_html()
		var speaker_color_close_bbcode: String = "[/color]"
		output_string += speaker_color_open_bbcode + voice_line.speaker.speaker_name.to_upper() + speaker_color_close_bbcode + ": "
	
	output_string += voice_line.subtitle_en
	_subtitle_label.text = output_string

func destroy() -> void:
	queue_free()
