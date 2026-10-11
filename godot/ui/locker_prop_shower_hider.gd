extends Node

@export var prop_item: Item

var prop: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prop = get_parent()
	
	show_or_hide_prop()


func show_or_hide_prop() -> void:
	var we_have_item_unlocked: bool = Global.unlocked_items.any(
			func(item):
				return item == prop_item
	)
	
	prop.visible = we_have_item_unlocked