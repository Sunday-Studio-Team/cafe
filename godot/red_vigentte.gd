class_name vignette_red extends ColorRect

func fade_to(target_alpha: float, duration: float = 0.5) -> void:
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
func set_alpha(target_alpha: float) -> void:
	modulate.a = clamp(target_alpha, 0.0, 1.0)
	
#func _ready() -> void:
	#set_alpha(0.0)
