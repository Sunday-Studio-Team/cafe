class_name LoadoutMenuElement
extends Button

## if false, this is one of the slots at the top showing available items
## if true, this is one of the slots at the bottom showing equipped items
var is_equipped_slot := false

var item: Item:
	set(new_item):
		item = new_item

		if item != null:
			icon = item.icon
		else:
			icon = null


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


# NOTE: all these drag/drop data funcs are built-ins for built-in Control node dragging stuff 🤯
func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null:
		return null

	var preview := duplicate()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)

	return self


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return (
			data is LoadoutMenuElement
			and data.item != null
			and data != self
	)


func _drop_data(at_position: Vector2, data: Variant) -> void:
	Global.item_loadout_menu.drop_dragged_element(data.item, data, self)
