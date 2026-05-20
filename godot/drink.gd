class_name Drink
extends Resource

enum MainIngredient { NONE, WRONG, COFFEE, TEA, CHAI }
enum Liquid { NONE, WRONG, WATER, MILK }
enum Extra { NONE, WRONG, SUGAR, ICE }

@export var name: String
@export var main_ingredient: MainIngredient
@export var liquid: Liquid
@export var extra: Extra
