extends PanelContainer
class_name EmailDrinkContainer

@export var drink_icon: TextureRect
@export var drink_name: Label
@export var main_icon: TextureRect
@export var liquid_icon: TextureRect
@export var extra_icon: TextureRect
@export var extra_panel: Control

var drink: Drink = null:
	set(value):
		if value == null:
			drink = null
			drink_icon.texture = null
		else:
			drink = value
			drink_icon.texture = drink.icon
			drink_name.text = drink.name
			main_icon.texture = drink.main_ingredient.icon
			liquid_icon.texture = drink.liquid.icon
			if (drink.extra):
				extra_icon.texture = drink.extra.icon
				extra_panel.visible = true
			else:
				extra_panel.visible = false

func init(d: Drink) -> void:
	drink = d
