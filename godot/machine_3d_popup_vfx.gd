class_name Machine3DPopupVfx
extends AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	hide()


func play_anim_then_hide(animation_name: String) -> void:
	await get_tree().create_timer(0.5, false).timeout
	scale = Vector3.ZERO
	show()
	play(animation_name)
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(
			self,
			"scale",
			Vector3.ONE,
			0.5
	)


func _on_animation_finished ()-> void:
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(
			self,
			"scale",
			Vector3.ZERO,
			0.1
	)
	await t.finished
	hide()
