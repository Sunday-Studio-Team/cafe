class_name LoadoutMenuElement
extends Button

var item: Item:
	set(new_item):
		item = new_item

		if item != null:
			icon = item.icon
		else:
			icon = null


func _ready() -> void:
	mouse_entered.connect(
		func():
			Global.hovered_loadout_menu_element = self,
	)
	mouse_exited.connect(
		func():
			Global.hovered_loadout_menu_element = null,
	)
