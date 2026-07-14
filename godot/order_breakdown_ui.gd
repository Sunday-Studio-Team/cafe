class_name OrderBreakdownElement
extends PanelContainer

enum Type { MAIN, LIQUID, EXTRA }

@export var type: Type
@export var star_ui: Control
@export var star_sign: Label
@export var icon: TextureRect

var ingredient: int = 0:
	set(value):
		icon.texture = null
		ingredient = value
		if type == Type.MAIN:
			icon.texture = Global.main_ingredient_icons.get(ingredient)
		if type == Type.LIQUID:
			icon.texture = Global.liquid_icons.get(ingredient)
		if type == Type.EXTRA:
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
