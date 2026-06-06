extends Interactable


func _on_interacted() -> void:
	super()
	enabled = false
	Events.shift_started.emit()
	rotation_degrees.y += 180
