class_name Machine3DPopupVfx
extends AnimatedSprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	hide()


func play_anim_then_hide(name: String) -> void:
	show()
	play(name)

func _on_animation_finished ()-> void:
	hide()
