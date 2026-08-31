@tool
class_name ShelfItem
extends Area3D

@export var sprite: Sprite3D

@export var _editor_update_pixel_size: bool = true

var item: Item
# we check this when we press sell so we cant spam and sell like 10 times
# before it hides for infinite money glitch
var clicked_sell := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	sprite.texture = item.icon
	
	_update_pixel_size()

	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and _editor_update_pixel_size:
		_update_pixel_size()

## Dyanmically scale based on import size.
func _update_pixel_size() -> void:
	if sprite.texture == null:
		return
	
	# Adjust this one to change size in game on shelf.
	# Higher = larger in game, Lower = smaller in game.
	const reference_pixel_size: float = 0.001 
	# Don't touch this one!
	const reference_size: float = 512.0
	sprite.pixel_size = reference_pixel_size * (reference_size / sprite.texture.get_size().x )
	
	# eg.
	# 0.001 = 0.001 * (512 / 512)
	# 0.00533 = 0.001 * (512 / 96)
