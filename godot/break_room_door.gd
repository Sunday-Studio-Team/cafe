extends Node3D

@export var close_sound: AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.shift_started.connect(_on_shift_started)


func _on_shift_started() -> void:
	create_tween().tween_property(self, "rotation:y", 0, 0.75)
	close_sound.play()
