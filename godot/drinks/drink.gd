class_name Drink
extends Resource

@export var name: String
@export var singular_article: String = "a"
@export var main_ingredient: Ingredient
@export var liquid: Ingredient
@export var extra: Ingredient
@export var icon: Texture2D
var price: float
var typing_minigame_ingredients_recipe: TypingMinigameContentIngredientsListRecipe = null

func create() -> void:
	typing_minigame_ingredients_recipe = TypingMinigameContentIngredientsListRecipe.new()
	price += main_ingredient.cost
	typing_minigame_ingredients_recipe.ingredient_names.append(main_ingredient.name_to_string())
	if liquid:
		typing_minigame_ingredients_recipe.ingredient_names.append(liquid.name_to_string())
		price += liquid.cost
	if extra:
		typing_minigame_ingredients_recipe.ingredient_names.append(extra.name_to_string())
		price += extra.cost
	price += 0.5

func get_score_from(drank: Drink) -> int:
	var myf = 0
	if drank.main_ingredient != main_ingredient:
		myf -= 1
	else:
		myf += 1
	if drank.liquid != liquid:
		myf -= 1
	else:
		myf += 1
	if drank.extra != extra:
		myf -= 1
	else:
		myf += 1
	return myf
