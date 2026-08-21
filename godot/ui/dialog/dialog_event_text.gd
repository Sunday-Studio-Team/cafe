class_name DialogEventText
extends DialogEvent

@export var dialog_character: DialogCharacter
@export var dialog_text: String

var _dialog_view: DialogView

func setup(dialog_view: DialogView):
	_dialog_view = dialog_view
	
func start_dialog_event() -> void:
	_dialog_view.show_dialog(dialog_character, dialog_text)
	await _dialog_view.typewriting_finished
	await _dialog_view.player_continued
	event_finished.emit(self)
