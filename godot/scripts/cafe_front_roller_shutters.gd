class_name CafeFrontRollerShutters
extends Node3D

@export var _animation_player: AnimationPlayer

func open() -> void:
	_animation_player.play("open")
