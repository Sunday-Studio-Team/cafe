class_name Desk
extends Node3D

@export var interactable: Interactable
@export var fabric_cover_for_monitor: Node3D


func _ready() -> void:
	await get_tree().process_frame

	fabric_cover_for_monitor.hide()
	interactable.show()
