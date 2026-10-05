class_name Drink
extends Resource

enum DrinkType { COFFEE, TEA, LATTE }

@export var name: String
@export var singular_article: String = "a"
@export var main_ingredient: Ingredient
@export var liquid: Ingredient
@export var extra: Ingredient
@export var icon: Texture2D
# coffee, tea, espresso (+iced ver) = day 1
# basic lattes (+iced ver) = day 2
# chai and matcha drinks (+iced ver) = day 3
# almond milk variations (+iced ver) = day 4
@export var day_unlocked: int = 0
# where it goes on the menu
@export var type: DrinkType
# incase u want to make the drink more expensive on top of the regular price when calculated
@export var upcharge: float = 1.00

var price: float


func calculate_price() -> void:
	price += main_ingredient.cost
	if liquid:
		price += liquid.cost
	if extra:
		price += extra.cost
	price += upcharge


func is_unlocked() -> bool:
	return Global.day >= day_unlocked
