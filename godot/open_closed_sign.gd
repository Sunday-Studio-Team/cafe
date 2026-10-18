class_name OpenClosedSign
extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer
@export var shift_start_triggered_sound: AudioStreamPlayer3D
@export var notice_particles: GPUParticles3D


func _ready() -> void:
	notice_particles.emitting = true
	interactable.interacted.connect(_on_interacted)


func set_enabled(enabled: bool) -> void:
	interactable.visible = enabled


func _on_interacted() -> void:
	notice_particles.emitting = false
	interactable.visible = false
	animation_player.play("open")
	shift_start_triggered_sound.play()
	Events.shutters_open_requested.emit()
	await animation_player.animation_finished
	Events.shift_start_requested.emit()
