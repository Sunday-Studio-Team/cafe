class_name PlayerDetectionArea
extends Area3D

@export var popup_this_is_camera: PackedScene #tutorial popup that shows player the camera

signal player_entered_area(detection_area: PlayerDetectionArea)
signal player_exited_area(detection_area: PlayerDetectionArea)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D):
	if body is Player:
		player_entered_area.emit(self)


func _on_body_exited(body: Node3D):
	if body is Player:
		player_exited_area.emit(self)
