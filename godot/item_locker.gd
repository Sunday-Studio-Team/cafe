class_name ItemLocker
extends Node3D

@export var _interactable: Interactable

func _ready() -> void:
	if Global.day == 0:
		_disable_item_locker()
	elif Global.day == 1:
		# If not unlocked item slots yet, disable.
		if SaveDataManager.save_data.latest_unlocked_day <= 1:
			_disable_item_locker()

func _disable_item_locker() -> void:
	visible = false
	_interactable.visible = false
		
