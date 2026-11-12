extends Control

@export var finished_drink: TextureRect
@export var root: Control


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data == finished_drink


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.hide()
	data.process_mode = ProcessMode.PROCESS_MODE_DISABLED
	root._end_minigame()
