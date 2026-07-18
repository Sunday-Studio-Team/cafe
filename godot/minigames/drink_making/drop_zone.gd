extends ColorRect

signal ingredient_dropped(id: String, correct: bool, id_satisfied: bool, source: Control)
signal phase_complete()

var required_ids: Array[String] = []
var _needed_counts: Dictionary = {}
var _collected_counts: Dictionary = {}
var _total_required: int = 0
var _total_collected: int = 0
var _locked: bool = false

func set_required_ids(ids: Array[String]) -> void:
	required_ids = ids.duplicate()
	_needed_counts.clear()
	for id in required_ids:
		_needed_counts[id] = _needed_counts.get(id, 0) + 1
	_collected_counts.clear()
	_total_required = required_ids.size()
	_total_collected = 0
	_locked = false
	color = Color.GRAY

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if _locked:
		return false
	return typeof(data) == TYPE_DICTIONARY and data.has("id")

func _drop_data(_at_position: Vector2, data) -> void:
	if _locked:
		return

	var id: String = data.id
	var needed: int = _needed_counts.get(id, 0)
	var have: int = _collected_counts.get(id, 0)
	var correct: bool = have < needed

	var id_satisfied := false
	if correct:
		_collected_counts[id] = have + 1
		_total_collected += 1
		id_satisfied = _collected_counts[id] >= needed
		color = Color.GREEN
	else:
		color = Color.RED

	ingredient_dropped.emit(id, correct, id_satisfied, data.source)

	if _total_collected == _total_required:
		_locked = true
		phase_complete.emit()
	else:
		await get_tree().create_timer(0.3).timeout
		if not _locked and _total_collected < _total_required:
			color = Color.GRAY
