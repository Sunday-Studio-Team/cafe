class_name TippyText
extends Sprite2D

@export var bubble_after_wet: Texture2D
@export var grow_count: int 
@export var speaking_gap: float
@export var scaling_factor: float
@export var tippy_bucket: Sprite2D
@export var tippy_bucket_normal: Texture2D
@export var tippy_bucket_mouth_closed: Texture2D


var grow_tween: Tween
var initial_scale: Vector2
var speaking_timer: Timer
var tippy_mouth_closed: bool


func _ready() -> void:
	grow_tween = create_tween()
	speaking_timer = Timer.new()
	add_child(speaking_timer)

	initial_scale = scale
	speaking_timer.wait_time = speaking_gap
	speaking_timer.timeout.connect(_speaking)
	
	_starting_animation(2)


func mop_entered() -> void:
	if grow_tween != null:
		grow_tween.kill()
		scale = initial_scale

	show()
	_start_speaking()

	texture = bubble_after_wet
	await get_tree().create_timer(2.5).timeout

	_stop_speaking()
	hide()


func _starting_animation(duration: float) -> void:
	_start_speaking()
	var grow_time := duration / grow_count
	
	for j in grow_count:
		grow_tween.tween_property(
			self,
			"scale",
			initial_scale * scaling_factor,
			grow_time / 2
		)
		
		grow_tween.tween_property(
			self,
			"scale",
			initial_scale,
			grow_time / 2
		)
	
	await get_tree().create_timer(duration + 1).timeout
	_stop_speaking()
	hide()


func _start_speaking() -> void:
	speaking_timer.start()


func _stop_speaking() -> void:
	speaking_timer.stop()
	tippy_bucket.texture = tippy_bucket_normal
	tippy_mouth_closed = false


func _speaking() -> void:
	tippy_mouth_closed = !tippy_mouth_closed
	if tippy_mouth_closed:
		tippy_bucket.texture = tippy_bucket_mouth_closed
	else:
		tippy_bucket.texture = tippy_bucket_normal
