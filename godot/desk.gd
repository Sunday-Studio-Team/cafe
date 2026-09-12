class_name Desk
extends Node3D

@export var interactable: Interactable
@export var fabric_cover_for_monitor: Node3D


func _ready() -> void:
	await get_tree().process_frame

	if Global.day <= 1:
		fabric_cover_for_monitor.show()
		interactable.hide()
	else:
		fabric_cover_for_monitor.hide()
		interactable.show()
