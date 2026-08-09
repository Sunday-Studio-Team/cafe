class_name DialogEventSequence
extends DialogEvent

@export var dialog_events: Array[DialogEvent]

func start_dialog_event() -> void:
	for dialog_event in dialog_events:
		dialog_event.start_dialog_event()
		await dialog_event.event_finished
	event_finished.emit(self)
