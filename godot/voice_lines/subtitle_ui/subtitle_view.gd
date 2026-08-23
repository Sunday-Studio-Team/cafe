class_name SubtitleView
extends Control

@export var _subtitle_label: RichTextLabel

func setup(voice_line: VoiceLine) -> void:	
	var voice_line_subtitle_en: String = voice_line.subtitle_en
	_subtitle_label.text = voice_line_subtitle_en

func destroy() -> void:
	queue_free()
