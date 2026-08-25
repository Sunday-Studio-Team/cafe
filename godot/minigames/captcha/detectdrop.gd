extends Container

@export var finished_drink: TextureRect
@export var root: SubViewportContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data == finished_drink


func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	print("Did not drop drink onto customer")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	finished_drink.texture = root.ordered_drink.icon
	visible = false
	return
