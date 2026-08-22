extends CanvasLayer

signal vo_started

@export var vo_player: AudioStreamPlayer
@export var sprite: AnimatedSprite2D

var playing_last_frame := false

@onready var sprite_starting_scale := sprite.scale


func _ready() -> void:
	sprite.modulate = Color.TRANSPARENT
	sprite.scale = Vector2.ZERO

	vo_started.connect(_on_vo_started)
	vo_player.finished.connect(_on_vo_finished)


func _physics_process(_delta: float) -> void:
	var playing := vo_player.playing

	if playing and not playing_last_frame:
		vo_started.emit()

	playing_last_frame = vo_player.playing


func _on_vo_started() -> void:
	var t := create_tween().set_parallel()
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	t.tween_property(sprite, "scale", sprite_starting_scale, 0.25)


func _on_vo_finished() -> void:
	var t := create_tween().set_parallel()
	t.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.25)
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.25)
