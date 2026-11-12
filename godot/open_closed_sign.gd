class_name OpenClosedSign
extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer
@export var shift_start_triggered_sound: AudioStreamPlayer3D
@export var notice_particles: GPUParticles3D


func _ready() -> void:
	Events.flipped_open_sign.connect(_on_sign_flipped)

	interactable.interacted.connect(
	func() -> void:
		Events.flipped_open_sign.emit()
	)


func _physics_process(_delta: float) -> void:
	notice_particles.emitting = interactable.visible


func set_enabled(enabled: bool) -> void:
	interactable.visible = enabled


func _on_sign_flipped() -> void:
	interactable.visible = false
	animation_player.play("open")
	shift_start_triggered_sound.play()
	await animation_player.animation_finished
	Events.shift_start_requested.emit()
