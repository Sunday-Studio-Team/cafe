extends Interactable
func _on_interacted() -> void:
	super()
	Global.employee_rating += 1
	queue_free()
