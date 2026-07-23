extends Resource
class_name Ingredient

# NOTE: WRONG values for testing purposes
enum Ingredient_Label { NONE, WRONG, COFFEE, ESPRESSO, GREEN_TEA, TEA, CHAI, WATER, MILK, SUGAR, ICE, ALMOND_MILK }
enum Ingredient_Type { NONE, MAIN, LIQUID, EXTRA } # only used in minigame atm

@export var icon: Texture2D
@export var name: Ingredient_Label
@export var type: Ingredient_Type
@export var cost: float
