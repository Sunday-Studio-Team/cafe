class_name ShelfItem
extends Area3D

@export var sprite: Sprite3D

var item: Item


func _ready() -> void:
	sprite.texture = item.icon
	sprite.position.y += sprite.texture.get_size().y / 2 * sprite.pixel_size

	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
