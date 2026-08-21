class_name Desk
extends Node3D

@export var interactable: Interactable


func _ready() -> void:
	await get_tree().process_frame
	if Global.day == 0:
		interactable.hide()
