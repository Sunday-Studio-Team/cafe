class_name FridgeTippy
extends Node3D

@export var _animation_player: AnimationPlayer

func _ready() -> void:
	_animation_player.play("Door fridge 2Action")
