class_name Teleporter
extends Area3D

@export var destination: Marker3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	print("teleport")
	if body is CharacterBody3D:
		body.global_position = destination.global_position
		body.rotation.y = destination.rotation.y - deg_to_rad(90)
		body.velocity = Vector3.ZERO
		body.reset_physics_interpolation()


func disable_teleporter():
	visible = false
	monitoring = false


func enable_teleporter():
	visible = true
	monitoring = true
