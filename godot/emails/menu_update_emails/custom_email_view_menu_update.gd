extends CustomEmailView	
class_name CustomEmailViewMenuUpdate

@export var drink_1: Control
@export var drinks_list: Control
@export var yes_button: TextureButton
@export var ok_button: TextureButton

func _ready() -> void:
	for drink: Drink in Global.drinks.filter(func(d: Drink): return d.day_unlocked == Global.day):
		var container = drink_1.duplicate()
		container.drink = drink
		drinks_list.add_child(container)
	# remove placehodler
	drinks_list.remove_child(drink_1) 	
	yes_button.pressed.connect(_on_button_pressed)
	ok_button.pressed.connect(_on_button_pressed)
	_update_buttons()

func _on_button_pressed() -> void:
	mark_finished_important()
	_update_buttons()

func _update_buttons() -> void:
	yes_button.disabled = is_finished_important
	ok_button.disabled = is_finished_important
	
	if is_finished_important:
		yes_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		ok_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		yes_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		ok_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
