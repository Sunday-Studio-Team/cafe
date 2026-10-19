class_name OpenClosedSign
extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer
@export var shift_start_triggered_sound: AudioStreamPlayer3D
@export var notice_particles: GPUParticles3D


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func _physics_process(delta: float) -> void:
	notice_particles.emitting = interactable.visible


func set_enabled(enabled: bool) -> void:
	interactable.visible = enabled


func _on_interacted() -> void:
	interactable.visible = false
	animation_player.play("open")
	shift_start_triggered_sound.play()
	Events.shutters_open_requested.emit()
	await animation_player.animation_finished
	Events.shift_start_requested.emit()
