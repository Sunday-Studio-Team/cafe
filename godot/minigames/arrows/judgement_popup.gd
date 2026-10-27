class_name JudgementText
extends Control
@export var texture_rect: TextureRect
@export var text_anim: AnimationPlayer
@export var judgment_textures: Array[Texture2D]
const PERFECT = 0
const GREAT = 1
const MISS = 2
func _ready() -> void:
	text_anim.play("disappear")
	await text_anim.animation_finished
	queue_free()

func set_judgement(index:int):
	texture_rect.texture = judgment_textures[index]
