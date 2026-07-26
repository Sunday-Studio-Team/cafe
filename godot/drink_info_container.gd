extends VBoxContainer
class_name DrinkInfoContainer

@export var drink_icon: TextureRect
@export var drink_name: Label
@export var drink_price: Label

var drink: Drink = null:
	set(value):
		if value == null:
			drink = null
			drink_icon.texture = null
		else:
			drink = value
			drink_icon.texture = drink.icon
			drink_price.text = str(drink.price)
			drink_name.text = drink.name
