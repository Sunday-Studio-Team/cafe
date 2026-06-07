extends Interactable


func _on_interacted() -> void:
	if Global.holding_ingredients:
		return
	super()
	Global.holding_ingredients = true
	queue_free()
