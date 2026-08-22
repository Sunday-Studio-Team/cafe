extends CenterContainer
@export var remade_drink_sprite: TextureRect
@export var root: SubViewportContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data == remade_drink_sprite

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	root._end_minigame()
	return
