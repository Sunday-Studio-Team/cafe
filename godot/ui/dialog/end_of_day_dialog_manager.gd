class_name EndOfDayDialogManager
extends Node

@export var _daily_dialog_sequences: Array[DialogEventSequence]
@export var _dialog_screen: DialogScreen

func _ready() -> void:
	await Events.scene_switch_in_animation_finished
	
	var day: int = Global.day
	var index: int = day - 1
	if index < _daily_dialog_sequences.size():
		var dialog_sequence: DialogEventSequence = _daily_dialog_sequences[index]
		if dialog_sequence == null:
			printerr("Dialog for the day is null!")
			return
		_dialog_screen.start_sequence(dialog_sequence)
		await _dialog_screen.finished_sequence
	else:
		printerr("No dialog for the day!")
	
	Global.day += 1
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
