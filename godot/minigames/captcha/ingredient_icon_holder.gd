class_name IngredientIconHolder
extends PanelContainer

enum Type { MAIN, LIQUID, EXTRA }

@export var type: Type
@export var icon: TextureRect
@export var button: Button
@export var button_disabled: bool

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

func _ready() -> void:
	button.disabled = button_disabled
