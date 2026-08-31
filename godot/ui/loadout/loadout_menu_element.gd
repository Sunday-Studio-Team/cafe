class_name LoadoutMenuElement
extends Button

enum Type {
	AVAILABE,
	EQUIPPED,
}

var type: Type
var item: Item:
	set(new_item):
		item = new_item

		if item != null:
			icon = item.icon
		else:
			icon = null


func _ready() -> void:
	if type == Type.AVAILABE:
		toggle_mode = true
	else:
		toggle_mode = false
