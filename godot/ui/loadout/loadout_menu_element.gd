class_name LoadoutMenuElement
extends TextureButton

## if false, this is one of the slots at the top showing available items
## if true, this is one of the slots at the bottom showing equipped items
var is_equipped_slot := false
@export var texture_rect: TextureRect

var item: Item:
	set(new_item):
		item = new_item

		if item != null:
			texture_rect.texture = item.icon
		else:
			texture_rect.texture = null


func _ready() -> void:
	# this stuff is for the tooltip
	mouse_entered.connect(
			func():
				Global.hovered_loadout_menu_element = self,
	)
	mouse_exited.connect(
			func():
				Global.hovered_loadout_menu_element = null,
	)
