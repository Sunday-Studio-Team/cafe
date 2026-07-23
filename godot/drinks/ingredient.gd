extends Resource
class_name Ingredient

# NOTE: WRONG values for testing purposes
enum Ingredient_Label { NONE, WRONG, COFFEE, GREEN_TEA, TEA, CHAI, WATER, MILK, SUGAR, ICE, ALMOND_MILK }

@export var icon: Texture2D
@export var name: Ingredient_Label
@export var cost: float
