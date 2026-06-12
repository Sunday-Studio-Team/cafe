class_name Item
extends Resource
## as of yet im not sure which makes the most sense
## - 1: having items as resources which the ingame stuff pulls the data from
## - 2: items as some kind of hardcoded global dictionary
## - 3: some combination <- probably this, with resource for assets and hardcoded stuff for behaviour ?

@export var name: String
@export var description: String
@export var icon: Texture
@export var price: float = 5
## this will be for showing the item physically on the shelf when we own it
## (we might actually just show the icon as a 3d sprite, im sorta just sketching here)
@export var model: PackedScene
## this will be for 'active items' we can pick up
@export var in_game_item: PackedScene
## stats (in the Stats autoload) and bonuses we'll add to them
## (there may be a nicer way to do this than just having them as strings but we'll get there)
@export var stat_bonuses: Dictionary
# this will be like stats but it can change vars in Global
@export var rules: Dictionary
