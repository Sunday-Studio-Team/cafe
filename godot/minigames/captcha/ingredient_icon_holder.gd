class_name IngredientIconHolder
extends PanelContainer

enum Type { MAIN, LIQUID, EXTRA }

@export var type: Type
@export var icon: TextureRect
@export var button: Button
@export var button_disabled: bool

var ingredient: Ingredient = null:
	set(value):
		if value == null:
			ingredient = null
			icon.texture = null
		else:
			ingredient = value
			icon.texture = ingredient.icon

func _ready() -> void:
	button.disabled = button_disabled
