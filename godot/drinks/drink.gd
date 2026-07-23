class_name Drink
extends Resource

# NOTE: WRONG values for testing purposes
enum MainIngredient { NONE, WRONG, COFFEE, TEA, CHAI }
enum Liquid { NONE, WRONG, WATER, MILK }
enum Extra { NONE, WRONG, SUGAR, ICE }
enum Type { COFFEE, TEA, CHAI_LATTE, ESPRESSO, ICED_CHAI_LATTE, ICED_ESPRESSO, ICED_LATTE, LATTE } # Same as the name just accessible in code

@export var name: String
@export var price: float = 3.00
@export var main_ingredient: MainIngredient
@export var liquid: Liquid
@export var extra: Extra
@export var typing_minigame_ingredients_recipe: TypingMinigameContentIngredientsListRecipe
