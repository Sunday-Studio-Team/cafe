@tool
class_name TypingMinigameContentFillBlanksSentence
extends Resource

## Used only for easier identification with the external document we're manually importing from.
@export var content_id: String 
@export_tool_button("Force update preview") var _editor_force_update_preview_action: Callable = _editor_force_update_preview
## Visual preview in editor only! Edit the `sentence_sections` content to update this.
@export_multiline var _editor_sentence_sections_combined_preview: String:
	get:
		var combined_preview: String = ""
		for sentence in sentence_sections:
			if sentence is TypingMinigameContentFillBlanksSentencePrefilledSection:
				combined_preview += sentence.prefilled_section
			elif sentence is TypingMinigameContentFillBlanksSentenceTypedSection:
				combined_preview += "\"%s\"" % sentence.typed_section
		_editor_sentence_sections_combined_preview = combined_preview
		return _editor_sentence_sections_combined_preview
## These should include spaces in the prefilled sections before and after the typed sections, where necessary.
## We want it to be formatted properly when put all together, and we also don't want the player to have to type spaces!
@export var sentence_sections: Array[TypingMinigameContentFillBlanksSentenceSection]

func _editor_force_update_preview() -> void:
	var _discard: String = _editor_sentence_sections_combined_preview
