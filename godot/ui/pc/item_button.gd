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
				clicked.emit(true)
				apply_stats()
				Global.bank_money -= item.price
				Global.owned_items.append(item)
				Events.items_updated.emit()
				queue_free()
			else:
				clicked.emit(false)
	)


func apply_stats():
	if item.stat_bonuses.is_empty():
		push_error("%s has no stat bonuses, can't apply stats" % item.name)
	for stat in item.stat_bonuses:
		var current_stat = Stats.current.get(stat)
		if current_stat == null:
			push_error("%s is trying to give a bonus to '%s' but that stat does not exist" % [item.name, stat])
		Stats.current.set(stat, current_stat + item.stat_bonuses[stat])
	for rule in item.rules:
		Global.set(rule, item.rules[rule])


func _on_clicked(bought: bool) -> void:
	if bought:
		pass
	else:
		create_tween().tween_property(self, "modulate", Color.WHITE, 1.0).from(Color.RED)
