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
@export var stat_bonuses: Dictionary
## this will be like stat_bonuses but it can change vars in Global
## NOTE: unused for now
@export var rules: Dictionary
#Determines if it's an active item 
#Does not go to shelf & instead inventory
#Used up after use
@export var is_active: bool = false
