extends CanvasLayer

@export var vo_player: AudioStreamPlayer
@export var sprite: AnimatedSprite2D

var playing_last_frame := false

@onready var sprite_starting_scale := sprite.scale


func _ready() -> void:
	sprite.modulate = Color.TRANSPARENT
	sprite.scale = Vector2.ZERO

	Global.voice_line_system.requested_show_voice_line_subtitle.connect(_on_vo_started)
	Global.voice_line_system.requested_hide_voice_line_subtitle.connect(_on_vo_finished)


func _on_vo_started(voice_line: VoiceLine) -> void:
	var t := create_tween().set_parallel()
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	t.tween_property(sprite, "scale", sprite_starting_scale, 0.25)


func _on_vo_finished(voice_line: VoiceLine) -> void:
	var t := create_tween().set_parallel()
	t.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.25)
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.25)
