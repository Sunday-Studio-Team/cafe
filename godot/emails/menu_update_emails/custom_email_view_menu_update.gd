extends CustomEmailViewDay_1_001
class_name CustomEmailViewMenuUpdate

@export var drink_1: Control
@export var drinks_list: Control

func populate_drinks() -> void:
	var container = drink_1.duplicate()
	for drink: Drink in Global.drinks.filter(func(d: Drink): return d.day_unlocked == Global.day):
		container.drink = drink
		drinks_list.add_child(container)
	# remove placehodler
	drinks_list.remove_child(drink_1) 	
