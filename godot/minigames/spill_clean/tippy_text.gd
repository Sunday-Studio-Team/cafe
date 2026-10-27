## idk why this script also controls the animation of the bucket itself
## but that's life .
class_name TippyText
extends Sprite2D

const NUMBER_OF_LOOPS_FOR_GROW_ANIMATION: int = 3
const MOUTH_ANIMATION_FRAME_DURATION: float = 0.2
const BUBBLE_SCALE_MULTIPLIER_AT_PEAK_OF_GROW_ANIMATION: float = 1.5
## meaning the full duration of it growing then shrinking back
const GROW_TWEEN_ANIMATION_DURATION: float = 1.5

@export var bucket: Sprite2D
@export var bucket_mouth_open_texture: Texture2D
@export var bucket_mouth_closed_texture: Texture2D

var text_bubble_grow_tween: Tween
## used to track the state of the bucket's talking animation
var bucket_mouth_open: bool = true

@onready var initial_scale := scale


func _ready() -> void:
	_animate_mouth()
	play_bubble_grow_animation()


func play_bubble_grow_animation() -> void:
	if text_bubble_grow_tween != null and text_bubble_grow_tween.is_running():
		return

	show()
	scale = initial_scale

	text_bubble_grow_tween = create_tween().set_loops(NUMBER_OF_LOOPS_FOR_GROW_ANIMATION)
	text_bubble_grow_tween.tween_property(
		self,
		"scale",
		initial_scale * BUBBLE_SCALE_MULTIPLIER_AT_PEAK_OF_GROW_ANIMATION,
		GROW_TWEEN_ANIMATION_DURATION / 2
	)
	text_bubble_grow_tween.tween_property(
		self,
		"scale",
		initial_scale,
		GROW_TWEEN_ANIMATION_DURATION / 2
	)

	await text_bubble_grow_tween.finished
	stop_bubble_animation()


func stop_bubble_animation() -> void:
	# the mouth animation's behaviour is tied to this tween,
	# so killing this stops that too
	text_bubble_grow_tween.kill()
	hide()
	scale = initial_scale


func _animate_mouth() -> void:
	if text_bubble_grow_tween != null and text_bubble_grow_tween.is_running():
		bucket_mouth_open = !bucket_mouth_open
		if bucket_mouth_open:
			bucket.texture = bucket_mouth_open_texture
		else:
			bucket.texture = bucket_mouth_closed_texture
	else:
		bucket_mouth_open = true
		bucket.texture = bucket_mouth_open_texture


	await get_tree().create_timer(MOUTH_ANIMATION_FRAME_DURATION, false).timeout
	_animate_mouth()
