extends CanvasLayer

@export var control_root: Control

## gets set to true when we move after prompt is shown
## (is just used to guard logic repeating)
var dismissed: bool = false


func _enter_tree() -> void:
	control_root.modulate.a = 0
	create_tween().tween_property(control_root, "modulate:a", 1.0, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Global.player.velocity.length() > 0.2 and not dismissed:
		dismissed = true

		await get_tree().create_timer(1.5, false).timeout

		var t: Tween = create_tween()
		t.tween_property(control_root, "modulate:a", 0.0, 1.0)
		await t.finished
		queue_free()
