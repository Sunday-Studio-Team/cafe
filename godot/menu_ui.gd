extends MarginContainer
class_name MenuUI

@export var coffee_drinks: Control
@export var tea_drinks: Control
@export var latte_drinks: Control
@export var specialty_drinks: Control


func populate_drinks() -> void:
	for drink: Drink in Global.drinks:
		pass
