extends Control

const IngredientScene := preload("res://minigames/drink_making/ingredient.tscn")
const ADVANCE_DELAY := 0.6
const RECIPE_REVEAL_TIME := 5.0

const RECIPES := [
	{
		"name": "coffee",
		"phases": [
			{
				"required_ids": ["coffee", "coffee", "coffee"],
				"options": [
					{"id": "water", "color": Color.BLUE},
					{"id": "coffee", "color": Color.BLACK},
					{"id": "nothing", "color": Color.WHITE},
				],
			},
			{
				"required_ids": ["black_tea"],
				"options": [
					{"id": "green_tea", "color": Color.MEDIUM_SEA_GREEN},
					{"id": "black_tea", "color": Color.GRAY},
					{"id": "matcha", "color": Color.SEA_GREEN},
					{"id": "coffee", "color": Color.ORANGE_RED},
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
				"required_ids": ["water", "water"],
				"options": [
					{"id": "water", "color": Color.BLUE},
					{"id": "coffee", "color": Color.BLACK},
					{"id": "nothing", "color": Color.WHITE},
				],
			},
			{
				"required_ids": ["black_tea"],
				"options": [
					{"id": "green_tea", "color": Color.MEDIUM_SEA_GREEN},
					{"id": "black_tea", "color": Color.GRAY},
					{"id": "matcha", "color": Color.SEA_GREEN},
					{"id": "coffee", "color": Color.ORANGE_RED},
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

func _on_recipe_closed() -> void:
	if _recipe_closed:
		return
	_recipe_closed = true
	_recipe_card.hide()
	_start_phase(0)

func _build_recipe_text() -> String:
	var lines := PackedStringArray()
	lines.append(_recipe.name)
	for phase in _recipe.phases:
		var counts: Dictionary = {}
		for id in phase.required_ids:
			counts[id] = counts.get(id, 0) + 1
		var names := PackedStringArray()
		for id in counts.keys():
			var count: int = counts[id]
			var label := _format_id(id)
			if count > 1:
				label += " x%d" % count
			names.append(label)
		lines.append(", ".join(names))
	return "\n".join(lines)

func _format_id(id: String) -> String:
	return id.replace("_", " ").capitalize()

var _phase_token := 0

func _start_phase(index: int) -> void:
	_phase_token += 1
	_phase_index = index
	_busy = false
	var typed_ids: Array[String] = Array(_recipe.phases[index].required_ids, TYPE_STRING, "", null)
	_drop_zone.set_required_ids(typed_ids)

	for child in _ingredient_holder.get_children():
		child.queue_free()

	var options: Array = _recipe.phases[index].options
	var seen_ids: Dictionary = {}
	var unique_options: Array = []
	for opt in options:
		if not seen_ids.has(opt.id):
			seen_ids[opt.id] = true
			unique_options.append(opt)

	unique_options.shuffle()
	for opt in unique_options:
		var inst := IngredientScene.instantiate()
		inst.ingredient_id = opt.id
		inst.ingredient_color = opt.color
		_ingredient_holder.add_child(inst)

func _on_ingredient_dropped(id: String, correct: bool, id_satisfied: bool, source: Control) -> void:
	if correct:
		print("correct: ", id)
		if id_satisfied and source and is_instance_valid(source):
			source.mouse_filter = Control.MOUSE_FILTER_IGNORE
			source.modulate.a = 0.3
	else:
		print("wrong or already used: ", )
	
func _on_phase_complete() -> void:
	if _busy:
		return
	_busy = true
	var token := _phase_token
	await get_tree().create_timer(ADVANCE_DELAY).timeout
	if token != _phase_token:
		return 
	if _phase_index + 1 < _recipe.phases.size():
		_start_phase(_phase_index + 1)
	else:
		print("complete")
