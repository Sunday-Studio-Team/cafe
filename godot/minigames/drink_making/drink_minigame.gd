extends Control

const IngredientScene := preload("res://minigames/drink_making/ingredient.tscn")
const ADVANCE_DELAY := 0.6
const RECIPE_REVEAL_TIME := 3.0

var _phases := [
	{
		"required_ids": ["blue_box", "purple_box"],
		"options": [
			{"id": "orange_box", "color": Color.ORANGE},
			{"id": "blue_box", "color": Color.BLUE},
			{"id": "purple_box", "color": Color.PURPLE},
			{"id": "yellow_box", "color": Color.YELLOW},
		],
	},
	{
		"required_ids": ["green_box"],
		"options": [
			{"id": "green_box", "color": Color.GREEN},
			{"id": "red_box", "color": Color.RED},
			{"id": "cyan_box", "color": Color.CYAN},
		],
	},
	{
		"required_ids": ["pink_box", "brown_box", "cyan_box"],
		"options": [
			{"id": "pink_box", "color": Color.PINK},
			{"id": "cyan_box", "color": Color.CYAN},
			{"id": "brown_box", "color": Color(0.4, 0.25, 0.1)},
			{"id": "yellow_box", "color": Color.YELLOW},
		],
	},
]

var _phase_index := 0
var _busy := false

@export var _ingredient_holder: HBoxContainer  
@export var _drop_zone: ColorRect 
@export var _recipe_card: PanelContainer 
@export var _recipe_label: Label 

func _ready() -> void:
	_drop_zone.ingredient_dropped.connect(_on_ingredient_dropped)
	_drop_zone.phase_complete.connect(_on_phase_complete)
	_show_recipe_card()

func _show_recipe_card() -> void:
	_recipe_card.show()
	_recipe_label.text = _build_recipe_text()

	await get_tree().create_timer(RECIPE_REVEAL_TIME).timeout
	_recipe_card.hide()
	_start_phase(0)

func _build_recipe_text() -> String:
	var lines := PackedStringArray()
	lines.append("Recipe:")
	for phase in _phases:
		var names := PackedStringArray()
		for id in phase.required_ids:
			names.append(_format_id(id))
		lines.append(", ".join(names))
	return "\n".join(lines)

func _format_id(id: String) -> String:
	return id.replace("_", " ").capitalize()

func _start_phase(index: int) -> void:
	_phase_index = index
	_busy = false
	var typed_ids: Array[String] = Array(_phases[index].required_ids, TYPE_STRING, "", null)
	_drop_zone.set_required_ids(typed_ids)

	for child in _ingredient_holder.get_children():
		child.queue_free()

	var options: Array = _phases[index].options.duplicate()
	options.shuffle()
	for opt in options:
		var inst := IngredientScene.instantiate()
		inst.ingredient_id = opt.id
		inst.ingredient_color = opt.color
		_ingredient_holder.add_child(inst)

func _on_ingredient_dropped(id: String, correct: bool, source: Control) -> void:
	if correct:
		print("Correct: ", id)
		if source and is_instance_valid(source):
			source.mouse_filter = Control.MOUSE_FILTER_IGNORE
			source.modulate.a = 0.3
	else:
		print("Wrong or already used: ", id)

func _on_phase_complete() -> void:
	if _busy:
		return
	_busy = true
	print("Phase complete! Advancing...")
	await get_tree().create_timer(ADVANCE_DELAY).timeout
	if _phase_index + 1 < _phases.size():
		_start_phase(_phase_index + 1)
	else:
		print("All phases complete!")
