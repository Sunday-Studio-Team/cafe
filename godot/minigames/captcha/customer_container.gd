extends CenterContainer
@export var finished_drink: TextureRect
@export var root: SubViewportContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data == finished_drink


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.is_dragging = false
	root._end_minigame()
	return
