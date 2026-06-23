extends Node3D

@export var shelf_item_scene: PackedScene
@export var item_slots_parent: Node3D

var item_slots: Array[Marker3D]


func _ready() -> void:
	item_slots.assign(item_slots_parent.get_children())
	display_items()
	Events.items_updated.connect(display_items)


func display_items() -> void:
	# items are cleared in main.gd so if we dont wait for that, shelf wont clear
	# properly on restart
	await get_tree().process_frame
	for item in Global.owned_items:
		#can change the visual of the item here
		var shelf_item: ShelfItem = shelf_item_scene.instantiate()
		shelf_item.item = item
		item_slots[Global.owned_items.find(item)].add_child(shelf_item)
