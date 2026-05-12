class_name Drink
extends Resource

enum MainIngredient { NONE, COFFEE, TEA, CHAI }
enum Liquid { NONE, WATER, MILK }
enum Extra { NONE, SUGAR, ICE }

# TODO: rename this to just 'drink' (couldnt before since Drink used to extend
# Node which has a built-in property called name)
@export var drink_name: String
@export var main_ingredient: MainIngredient
@export var liquid: Liquid
@export var extra: Extra
