class_name Item
extends Resource

@export var name: String
@export var description: String
@export var icon: Texture
@export var price: float = 5
## this will be for 'active items' we can pick up
## NOTE: unused as of now
@export var in_game_item: PackedScene
## stats (in the Stats autoload) and bonuses we'll add to them
## (there may be a nicer way to do this than just having them as strings but we'll get there)
##
## Dropdown options are taken from an auto-generated enum based on stat_data.gd.
## Due to Godot limitations, the editor must be restarted for the dropdown to be updated. 
# TYPE_STRING = 4
# PROPERTY_HINT_ENUM = 2 / PROPERTY_HINT_ENUM_SUGGESTION = 3
# TYPE_FLOAT = 3
@export_custom(PROPERTY_HINT_TYPE_STRING, "4/3:%s;3:" % StatDataEnum.VALUES) var stat_bonuses: Dictionary[String, float]
## this will be like stat_bonuses but it can change vars in Global
## NOTE: unused for now
@export var rules: Dictionary
