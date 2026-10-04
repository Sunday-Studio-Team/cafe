class_name OpenClosedSign
extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

func set_enabled(enabled: bool) -> void:
	interactable.visible = enabled

func _on_interacted() -> void:
	interactable.visible = false
	Events.shift_started.emit()
	animation_player.play("open")
