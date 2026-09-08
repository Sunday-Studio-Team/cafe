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
			drink_price.text = Global.float_to_price(drink.price * Stats.current.drink_price_multiplier_each_day[Global.day])
			drink_name.text = drink.name
