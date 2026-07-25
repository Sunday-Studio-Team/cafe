extends Resource
class_name Ingredient

# NOTE: WRONG values for testing purposes
enum Ingredient_Label { NONE, WRONG, COFFEE, ESPRESSO, GREEN_TEA, TEA, CHAI, WATER, MILK, SUGAR, ICE, ALMOND_MILK }
enum Ingredient_Type { NONE, MAIN, LIQUID, EXTRA } # only used in minigame atm

@export var icon: Texture2D
@export var name: Ingredient_Label
@export var type: Ingredient_Type
@export var cost: float
var similar_ingredients: Array[Ingredient_Label] = [ ]

func name_to_string() -> String:
	match name:
		Ingredient_Label.NONE:
			return "none"
		Ingredient_Label.WRONG:
			return "wrong"
		Ingredient_Label.COFFEE:
			return "coffee"
		Ingredient_Label.ESPRESSO:
			return "espresso"
		Ingredient_Label.GREEN_TEA:
			return "green tea"
		Ingredient_Label.TEA:	
			return "tea"
		Ingredient_Label.CHAI:
			return "chai"
		Ingredient_Label.WATER:
			return "water"
		Ingredient_Label.MILK:
			return "milk"
		Ingredient_Label.SUGAR:
			return "sugar"
		Ingredient_Label.ICE:
			return "ice"
		Ingredient_Label.ALMOND_MILK:
			return "almond milk"	
		_:
			return "unknown"

func get_similar() -> void:
	match Ingredient_Label:
		Ingredient_Label.COFFEE:
			similar_ingredients.append(Ingredient_Label.ESPRESSO)
		Ingredient_Label.ESPRESSO:
			similar_ingredients.append(Ingredient_Label.COFFEE)
		Ingredient_Label.CHAI:
			similar_ingredients.append(Ingredient_Label.TEA)
		Ingredient_Label.TEA:
			similar_ingredients.append(Ingredient_Label.CHAI)
			similar_ingredients.append(Ingredient_Label.GREEN_TEA)
		Ingredient_Label.GREEN_TEA:
			similar_ingredients.append(Ingredient_Label.TEA)
		Ingredient_Label.MILK:
			similar_ingredients.append(Ingredient_Label.ALMOND_MILK)
		Ingredient_Label.ALMOND_MILK:
			similar_ingredients.append(Ingredient_Label.MILK)
