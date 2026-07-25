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
#Active Items
@export var is_active_item: bool = false
# if true, we show a buttom prompt to press Q to use the item whenever its equipped
# (disable for items like the hammer which can only be used on other objects etc)
# NOTE: only relevant for active items
@export var can_activate_anywhere: bool = true

var can_be_used: bool = true #Set to false when the item is used


func apply_stats() -> void:
	if stat_bonuses.is_empty():
		push_warning("%s has no stat bonuses, not applying stats" % name)
	for stat in stat_bonuses:
		var current_stat = Stats.current.get(stat)
		if current_stat == null:
			push_error("%s is trying to give a bonus to '%s' but that stat does not exist" % [name, stat])
		Stats.current.set(stat, current_stat + stat_bonuses[stat])
	for rule in rules:
		Global.set(rule, rules[rule])


# for when we sell items
func unapply_stats() -> void:
	if stat_bonuses.is_empty():
		push_warning("%s has no stat bonuses, not unapplying stats" % name)
	for stat in stat_bonuses:
		var current_stat = Stats.current.get(stat)
		if current_stat == null:
			push_error("%s is trying to take a bonus from '%s' but that stat does not exist" % [name, stat])
		Stats.current.set(stat, current_stat - stat_bonuses[stat])
