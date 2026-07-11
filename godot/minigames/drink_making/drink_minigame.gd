extends Control

const IngredientScene := preload("res://minigames/drink_making/ingredient.tscn")
const ADVANCE_DELAY := 0.6
const RECIPE_REVEAL_TIME := 5.0

const RECIPES := [
	{
		"name": "coffee",
		"phases": [
			{
				"required_ids": ["coffee"],
				"options": [
					{"id": "water", "color": Color.BLUE},
					{"id": "coffee", "color": Color.BLACK},
					{"id": "milk", "color": Color.WHITE},
				],
			},
			{
				"required_ids": ["black_tea"],
				"options": [
					{"id": "green_tea", "color": Color.MEDIUM_SEA_GREEN},
					{"id": "black_tea", "color": Color.DARK_SLATE_GRAY},
					{"id": "matcha", "color": Color.SEA_GREEN},
					{"id": "thai", "color": Color.ORANGE_RED},
				],
			},
			{
				"required_ids": ["nothing"],
				"options": [
					{"id": "boba", "color": Color.DIM_GRAY},
					{"id": "cream", "color": Color.GHOST_WHITE},
					{"id": "nothing", "color": Color.BEIGE},
					{"id": "ice", "color": Color.SKY_BLUE},
				],
			},
		],
	},
	
	{
		"name": "thai",
		"phases": [
			{
				"required_ids": ["water"],
				"options": [
					{"id": "water", "color": Color.BLUE},
					{"id": "coffee", "color": Color.BLACK},
					{"id": "milk", "color": Color.WHITE},
				],
			},
			{
				"required_ids": ["thai"],
				"options": [
					{"id": "green_tea", "color": Color.MEDIUM_SEA_GREEN},
					{"id": "black_tea", "color": Color.DARK_SLATE_GRAY},
					{"id": "matcha", "color": Color.SEA_GREEN},
					{"id": "thai", "color": Color.ORANGE_RED},
				],
			},
			{
				"required_ids": ["ice", "cream"],
				"options": [
					{"id": "boba", "color": Color.DIM_GRAY},
					{"id": "cream", "color": Color.GHOST_WHITE},
					{"id": "nothing", "color": Color.BEIGE},
					{"id": "ice", "color": Color.SKY_BLUE},
				],
			},
		],
	},
]


var _recipe: Dictionary
var _phase_index := 0
var _busy := false
var _recipe_closed := false

@export var _ingredient_holder: HBoxContainer  
@export var _drop_zone: ColorRect 
@export var _recipe_card: PanelContainer 
@export var _recipe_label: Label 
@export var _close_recipe: Button


func _ready() -> void:
	_drop_zone.ingredient_dropped.connect(_on_ingredient_dropped)
	_drop_zone.phase_complete.connect(_on_phase_complete)
	_close_recipe.pressed.connect(_on_recipe_closed)
	_recipe = RECIPES[randi() % RECIPES.size()]
	_show_recipe_card()

func _show_recipe_card() -> void:
	_recipe_closed = false
	_recipe_card.show()
	_recipe_label.text = _build_recipe_text()

	await get_tree().create_timer(RECIPE_REVEAL_TIME).timeout
	_on_recipe_closed()
	_start_phase(0)

func _on_recipe_closed() -> void:
	if _recipe_closed:
		return
	_recipe_closed = true
	_recipe_card.hide()
	_start_phase(0)

func _build_recipe_text() -> String:
	var lines := PackedStringArray()
	lines.append("Recipe: " + _recipe.name)
	for phase in _recipe.phases:
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
	var typed_ids: Array[String] = Array(_recipe.phases[index].required_ids, TYPE_STRING, "", null)
	_drop_zone.set_required_ids(typed_ids)

	for child in _ingredient_holder.get_children():
		child.queue_free()

	var options: Array = _recipe.phases[index].options.duplicate()
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
	if _phase_index + 1 < _recipe.phases.size():
		_start_phase(_phase_index + 1)
	else:
		print("All phases complete!")
