class_name Drink
extends Resource

enum MainIngredient { NONE, COFFEE, TEA, CHAI }
enum Liquid { NONE, WATER, MILK }
enum Extra { NONE, SUGAR, ICE }

@export var name: String
@export var main_ingredient: MainIngredient
@export var liquid: Liquid
@export var extra: Extra
