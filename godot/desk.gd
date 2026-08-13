class_name Desk
extends Node3D

@export var interactable: Interactable

func disable_interactable() -> void:
	interactable.visible = false
