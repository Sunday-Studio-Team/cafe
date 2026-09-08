extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	interactable.visible = false
	Events.shift_started.emit()
	animation_player.play("open")
