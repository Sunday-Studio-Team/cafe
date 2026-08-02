class_name ItemButton
extends Button
## script for the items that show up in the shop
## (which you click on to buy the item)

signal item_button_pressed(item_button: ItemButton)

@export var item_icon: TextureRect
@export var item_name: RichTextLabel
@export var description: Label

var item: Item

func _ready() -> void:
	item_icon.texture = item.icon
	item_name.text = "[b]%s [color=gold](%s)" % [item.name, Global.float_to_price(item.price)]
	description.text = item.description

	pressed.connect(_on_button_pressed)

	set_up_tweens()


func set_up_tweens() -> void:
	const DUR := 0.25

	mouse_entered.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(self, "offset_transform_rotation", deg_to_rad(randf_range(-1, 1)), DUR)
			t.tween_property(self, "offset_transform_position_ratio:y", -0.025, DUR)
	)
	mouse_exited.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(self, "offset_transform_rotation", 0, DUR)
			t.tween_property(self, "offset_transform_position_ratio:y", 0, DUR)
	)

func notify_pressed(did_buy_item: bool) -> void:
	if did_buy_item:
		#TODO REMOVE AND CHANGE
		if item.is_active_item:
			#Global.equipped_item = item
			Global.equip_item(item)
			print("Equipped: ", Global.equipped_item)
		pass
	else:
		create_tween().tween_property(self, "modulate", Color.WHITE, 1.0).from(Color.RED)


func _on_button_pressed() -> void:
	item_button_pressed.emit(self)
