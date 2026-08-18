class_name IngredientSpawner
extends Node3D

@export var _ingredient_spawn_points: Array[Node3D]
@export var _ingredients_bag_packed_scene: PackedScene

var _empty_spawn_points: Array[Node3D]
var _bag_to_spawn_point: Dictionary[IngredientsBag, Node3D]

func _ready() -> void:
	Events.ingredients_bag_consumed.connect(_on_ingredients_bag_consumed)
	_empty_spawn_points = _ingredient_spawn_points.duplicate()
	for spawn_point in _ingredient_spawn_points:
		_spawn_ingredient_at_point(spawn_point)

func _spawn_ingredient_at_point(spawn_point: Node3D) -> void:
	if _empty_spawn_points.has(spawn_point):
		var index: int = _empty_spawn_points.find(spawn_point)
		_empty_spawn_points.remove_at(index)
	
	var ingredients_bag: IngredientsBag = _ingredients_bag_packed_scene.instantiate()
	spawn_point.add_child(ingredients_bag, true)
	ingredients_bag.global_transform = spawn_point.global_transform
	_bag_to_spawn_point[ingredients_bag] = spawn_point
	ingredients_bag.ingredients_bag_taken.connect(_on_ingredients_bag_taken)

func _on_ingredients_bag_taken(ingredients_bag: IngredientsBag) -> void:
	if !_bag_to_spawn_point.has(ingredients_bag):
		printerr("Bag has no associated spawn point?")
		return
	var spawn_point: Node3D = _bag_to_spawn_point[ingredients_bag]
	_empty_spawn_points.append(spawn_point)
	_bag_to_spawn_point.erase(ingredients_bag)

func _on_ingredients_bag_consumed() -> void:
	if _empty_spawn_points.size() == 0:
		printerr("No free ingredients spawn points. This should never be the case?")
		return
	var spawn_point: Node3D = _empty_spawn_points.pick_random()
	_spawn_ingredient_at_point(spawn_point)
