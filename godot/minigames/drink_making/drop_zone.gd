extends ColorRect

signal ingredient_dropped(id: String, correct: bool, source: Control)
signal phase_complete()

var required_ids: Array[String] = []
var _collected: Array[String] = []

func set_required_ids(ids: Array[String]) -> void:
	required_ids = ids.duplicate()
	_collected.clear()
	color = Color.GRAY

func _can_drop_data(_at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("id")

func _drop_data(_at_position: Vector2, data) -> void:
	var id: String = data.id
	var needed: bool = required_ids.has(id)
	var already_have: bool = _collected.has(id)
	var correct: bool = needed and not already_have

	if correct:
		_collected.append(id)
		color = Color.GREEN
	else:
		color = Color.RED

	ingredient_dropped.emit(id, correct, data.source)

	if _collected.size() == required_ids.size():
		phase_complete.emit()
	else:
		await get_tree().create_timer(0.3).timeout
		if _collected.size() < required_ids.size():
			color = Color.GRAY
