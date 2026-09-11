class_name OrderBreakdownElement
extends PanelContainer

enum Type { MAIN, LIQUID, EXTRA }

@export var type: Type
@export var star_ui: Control
@export var star_sign: Label
@export var icon: TextureRect
@export var style_array: Array[StyleBoxFlat]
enum Style {
	Default,
	Correct,
	Wrong
}

var ingredient: Ingredient = null:
	set(value):
		if value == null:
			ingredient = null
			icon.texture = null
			remove_theme_stylebox_override("panel")
			add_theme_stylebox_override("panel",style_array[Style.Default])
		else:
			ingredient = value
			icon.texture = ingredient.icon

var correct: bool = false:
	set(value):
		correct = value

		if correct:
			#modulate = Color.GREEN
			remove_theme_stylebox_override("panel")
			add_theme_stylebox_override("panel",style_array[Style.Correct])
			star_sign.text = "+"
		else:
			#modulate = Color.RED
			remove_theme_stylebox_override("panel")
			add_theme_stylebox_override("panel",style_array[Style.Wrong])
			star_sign.text = "-"
