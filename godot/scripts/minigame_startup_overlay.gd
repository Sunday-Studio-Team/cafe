class_name MinigameStartupOverlay
extends Control

@export var _animation_player: AnimationPlayer
@export var _label: Label

func play(overlay_text: String) -> void:
	_label.text = overlay_text
	visible = true
	_animation_player.play("appear")
	await _animation_player.animation_finished
	visible = false
