class_name TypingMinigameVariantFillBlanksPrefilledSection
extends Control

@export var rich_text_label: RichTextLabel

var _prefilled_text: String

func init(prefilled_text: String) -> void:
	_prefilled_text = prefilled_text
	
	rich_text_label.text = str("[color=black]",_prefilled_text,"[/color]")
