extends Control

@export var item_icons: Control


func _ready() -> void:
	await get_tree().process_frame
	populate_items()
	Events.items_updated.connect(populate_items)


func populate_items() -> void:
	var i := 0
	for icon: TabletItemIcon in item_icons.get_children():
		if Global.owned_items.size() >= i + 1:
			icon.item = Global.owned_items[i]
		else:
			icon.item = null
		i += 1
