class_name DialogScreen
extends Control

signal finished_sequence

@export var _dialog_view: DialogView
@export var _dialog_options_view: DialogOptionsView

func _init() -> void:
	visible = false

func _ready() -> void:
	visible = true
	_dialog_view.visible = false

func start_sequence(dialog_event_sequence: DialogEventSequence) -> void:
	_dialog_view.visible = true
	Global.in_dialog_screen = true
	setup_events_recursively(dialog_event_sequence)
	dialog_event_sequence.start_dialog_event()
	await dialog_event_sequence.event_finished
	_dialog_view.visible = false
	Global.in_dialog_screen = false
	finished_sequence.emit()

func setup_events_recursively(dialog_event: DialogEvent) -> void:
	if dialog_event is DialogEventText:
		var dialog_event_text: DialogEventText = dialog_event as DialogEventText
		dialog_event_text.setup(_dialog_view)
	elif dialog_event is DialogEventOptions:
		var dialog_event_options: DialogEventOptions = dialog_event as DialogEventOptions
		dialog_event_options.setup(_dialog_options_view)
		for dialog_option in dialog_event_options.dialog_options:
			var dialog_option_sequence: DialogEventSequence = dialog_option.dialog_event_sequence
			if dialog_option_sequence != null:
				setup_events_recursively(dialog_option_sequence)
	elif dialog_event is DialogEventSequence:
		var dialog_event_sequence: DialogEventSequence = dialog_event as DialogEventSequence
		for dialog_event_sequence_dialog_event in dialog_event_sequence.dialog_events:
			setup_events_recursively(dialog_event_sequence_dialog_event)
	else:
		printerr("DialogEvent type not set up.")
		return
