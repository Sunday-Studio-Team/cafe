class_name Item
extends Resource

@export var name: String
@export var description: String
@export var icon: Texture
@export var price: float = 5
## this will be for 'active items' we can pick up
## NOTE: unused as of now
@export var in_game_item: PackedScene
## Dropdown options are taken from an auto-generated enum based on stat_data.gd.
## Due to Godot limitations, the project must be reloaded for the dropdown to be updated.
# TYPE_STRING = 4
# PROPERTY_HINT_ENUM = 2 / PROPERTY_HINT_ENUM_SUGGESTION = 3
# TYPE_FLOAT = 3
@export_custom(PROPERTY_HINT_TYPE_STRING, "4/3:%s;3:" % StatDataEnum.VALUES) var stat_bonuses: Dictionary[String, float]
## this will be like stat_bonuses but it can change vars in Global
## NOTE: unused for now
@export var rules: Dictionary


func apply_stats():
	if stat_bonuses.is_empty():
		push_warning("%s has no stat bonuses, not applying stats" % name)
	for stat in stat_bonuses:
		var current_stat = Stats.current.get(stat)
		if current_stat == null:
			push_error("%s is trying to give a bonus to '%s' but that stat does not exist" % [name, stat])
		Stats.current.set(stat, current_stat + stat_bonuses[stat])
	for rule in rules:
		Global.set(rule, rules[rule])
