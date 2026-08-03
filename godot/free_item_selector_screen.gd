class_name FreeItemSelectorScreen
extends Control

signal finished_selection

@export var _num_items_to_display: int = 3
@export var _item_button_packed_scene: PackedScene
@export var _item_buttons_container: Control

func _ready() -> void:
	var items_to_display: Array[Item] = ShopApp.get_random_unowned_items(_num_items_to_display)
	for item in items_to_display:
		var item_button: ItemButton = _item_button_packed_scene.instantiate()
		item_button.item = item
		item_button.item_button_pressed.connect(_on_item_button_pressed)
		_item_buttons_container.add_child(item_button)

func _on_item_button_pressed(item_button: ItemButton) -> void:
	var item: Item = item_button.item
	ShopApp.own_and_apply_item(item)
	finished_selection.emit()
