class_name ItemLockerModel
extends Node3D

const DOOR_Y_ANGLE_WHEN_CLOSED := 177.3
const DOOR_Y_ANGLE_WHEN_OPEN := 310

@export var door_mesh: MeshInstance3D


func open_door() -> void:
	var t := create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(
			door_mesh, 
			"rotation:y", 
			deg_to_rad(DOOR_Y_ANGLE_WHEN_OPEN), 
			0.25
	)
	await t.finished


func close_door() -> void:
	create_tween().set_ease(Tween.EASE_OUT).tween_property(
			door_mesh, 
			"rotation:y", 
			deg_to_rad(DOOR_Y_ANGLE_WHEN_CLOSED),
			0.25
	)
