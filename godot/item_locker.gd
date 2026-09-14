class_name ItemLocker
extends Node3D

@export var _interactable: Interactable


func _ready() -> void:
	# if we're in the tutorial or we haven't beaten day 1
	# (we want to have the locker if we're replaying day 1 after beating it, but not before)
	if Global.day == 0 or SaveDataManager.save_data.latest_unlocked_day <= 1:
		hide()
		process_mode = ProcessMode.PROCESS_MODE_DISABLED

	Events.shift_started.connect(
			func() -> void:
				_interactable.hide()
	)
