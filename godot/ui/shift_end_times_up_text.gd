extends TextureRect

var degrees_to_rotate := 10.0


func _ready() -> void:
	Events.time_up.connect(_on_time_up)


func _on_time_up() -> void:
	var scale_tween := create_tween().set_trans(Tween.TRANS_BOUNCE)
	scale_tween.tween_property(
			self,
			"offset_transform_scale",
			Vector2.ONE,
			0.25
	).from(Vector2.ZERO)

	play_rotate_tween()


# i know theres like a nicer way to loop this with callbacks or something but
# i couldnt figure it out .
func play_rotate_tween() -> void:
	var rotate_tween := create_tween()
	rotate_tween.tween_property(
			self,
			"offset_transform_rotation",
			abs(deg_to_rad(degrees_to_rotate)),
			0.1
	)
	rotate_tween.tween_property(
			self,
			"offset_transform_rotation",
			-abs(deg_to_rad(degrees_to_rotate)),
			0.1
	)
	await rotate_tween.finished
	degrees_to_rotate -= 1
	degrees_to_rotate = clampf(degrees_to_rotate, 0, INF)
	play_rotate_tween()
