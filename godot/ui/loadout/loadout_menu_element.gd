class_name LoadoutMenuElement
extends Button

@export var is_equipped_slot := false
@export var loadout_menu: CanvasLayer

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

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null:
		return null
		
	var preview := duplicate()
	preview.size = size
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_drag_preview(preview)
	
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return (
		is_equipped_slot
		and data is LoadoutMenuElement
		and data.item != null
		and data != self
	)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	loadout_menu.move_item_to_equipped(data.item, data, self)
