class_name CafeFrontRollerShutters
extends Node3D

@export var _animation_player: AnimationPlayer
@export var _opening_sound: AudioStreamPlayer3D


func open() -> void:
	_animation_player.play("open")
	_opening_sound.play()
