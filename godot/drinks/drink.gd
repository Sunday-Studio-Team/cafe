class_name Drink
extends Resource

@export var name: String
@export var price: float
@export var main_ingredient: Ingredient
@export var liquid: Ingredient
@export var extra: Ingredient
@export var typing_minigame_ingredients_recipe: TypingMinigameContentIngredientsListRecipe

func _init() -> void:
	price += main_ingredient.cost
	if liquid:
		price += liquid.cost
	if extra:
		price += extra.cost
	price += 1.0
