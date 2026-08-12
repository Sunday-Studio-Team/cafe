class_name Teleporter
extends Area3D

@export var destination: Marker3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	print("teleport")
	if body is CharacterBody3D:
		body.global_position = destination.global_position


func disable_teleporter():
	visible = false
	monitoring = false


func enable_teleporter():
	visible = true
	monitoring = true
