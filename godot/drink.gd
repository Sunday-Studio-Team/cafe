class_name Drink
extends Resource

enum MainIngredient { NONE, WRONG, COFFEE, TEA, CHAI }
enum Liquid { NONE, WRONG, WATER, MILK }
enum Extra { NONE, WRONG, SUGAR, ICE }

# TODO: rename this to just 'name' (couldnt before since Drink used to extend
# Node which has a built-in property called name)
@export var drink_name: String
@export var main_ingredient: MainIngredient
@export var liquid: Liquid
@export var extra: Extra
