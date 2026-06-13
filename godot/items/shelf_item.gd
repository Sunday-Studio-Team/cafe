class_name ShelfItem
extends Node3D

@export var sprite: Sprite3D

var item: Item


func _ready() -> void:
	sprite.texture = item.icon
	sprite.position.y += sprite.texture.get_size().y / 2 * sprite.pixel_size
