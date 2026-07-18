class_name ItemButton
extends Button
## script for the items that show up in the shop
## (which you click on to buy the item)

## sorry for confusing naming since this is similar to pressed
## but i wanted a version with an arg for whether we had enough money to buy
## when we clicked it lol
signal clicked(bought: bool)

@export var item_icon: TextureRect
@export var item_name: RichTextLabel
@export var description: Label

var item: Item


func _ready() -> void:
	item_icon.texture = item.icon
	item_name.text = "[b]%s [color=gold](%s)" % [item.name, Global.float_to_price(item.price)]
	description.text = item.description

	clicked.connect(_on_clicked)

	pressed.connect(
		func():
			if Global.bank_money >= item.price:
				if Global.owned_items.size() < Global.item_slots_amount:
					clicked.emit(true)
					item.apply_stats()
					Global.bank_money -= item.price
					Global.owned_items.append(item)
					Events.items_updated.emit()
					queue_free()
				else:
					clicked.emit(false)
			else:
				clicked.emit(false)
	)


func _on_clicked(bought: bool) -> void:
	if bought:
		pass
	else:
		create_tween().tween_property(self, "modulate", Color.WHITE, 1.0).from(Color.RED)
