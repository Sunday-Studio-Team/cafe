class_name DialogEventOptions
extends DialogEvent

@export var dialog_options: Array[DialogOption]

var _dialog_options_view: DialogOptionsView

func setup(dialog_options_view: DialogOptionsView) -> void:
	_dialog_options_view = dialog_options_view

func start_dialog_event() -> void:
	_dialog_options_view.show_options(self)
	await _dialog_options_view.selected_option
	var selected_option: DialogOption = _dialog_options_view.get_selected_option()
	var option_sequence: DialogEventSequence = selected_option.dialog_event_sequence
	if option_sequence != null:
		option_sequence.start_dialog_event()
		await option_sequence.event_finished
	event_finished.emit(self)
