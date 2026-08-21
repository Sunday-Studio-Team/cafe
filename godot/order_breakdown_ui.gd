class_name OrderBreakdownElement
extends PanelContainer

enum Type { MAIN, LIQUID, EXTRA }

@export var type: Type
@export var star_ui: Control
@export var star_sign: Label
@export var icon: TextureRect

var ingredient: Ingredient = null:
	set(value):
		if value == null:
			ingredient = null
			icon.texture = null
		else:
			ingredient = value
			icon.texture = ingredient.icon

var correct: bool = false:
	set(value):
		correct = value

		if correct:
			modulate = Color.GREEN
			star_sign.text = "+"
		else:
			modulate = Color.RED
			star_sign.text = "-"
