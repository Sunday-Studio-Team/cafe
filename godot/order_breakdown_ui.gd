class_name OrderBreakdownElement
extends PanelContainer

@export var star_ui: Control
@export var star_sign: Label
@export var icon: TextureRect

var ingredient:
	set(value):
		icon.texture = null
		ingredient = value
		if ingredient is Drink.MainIngredient:
			icon.texture = Global.main_ingredient_icons.get(ingredient)
		elif ingredient is Drink.Liquid:
			icon.texture = Global.liquid_icons.get(ingredient)
		elif ingredient is Drink.Extra:
			icon.texture = Global.extra_icons.get(ingredient)
var correct: bool = false:
	set(value):
		correct = value

		if correct:
			modulate = Color.GREEN
			star_sign.text = "+"
		else:
			modulate = Color.RED
			star_sign.text = "-"
