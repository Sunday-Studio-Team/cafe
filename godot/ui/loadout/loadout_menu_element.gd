class_name LoadoutMenuElement
extends Button

var item: Item:
	set(new_item):
		item = new_item

		if item != null:
			icon = item.icon
		else:
			icon = null
