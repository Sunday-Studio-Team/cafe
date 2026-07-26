extends MarginContainer
class_name MenuUI

@export var coffee_drinks: Control
@export var coffee_1: Control
@export var tea_drinks: Control
@export var latte_drinks: Control
@export var specialty_drinks: Control


func populate_drinks() -> void:
	for drink: Drink in Global.drinks:
		var container = coffee_1.duplicate()
		container.drink = drink
		match drink.type:
			1:
				coffee_drinks.add_child(container)
			2:
				tea_drinks.add_child(container)
			3:
				latte_drinks.add_child(container)
			4:
				specialty_drinks.add_child(container)
	# remove placehodler
	coffee_drinks.remove_child(coffee_1)
