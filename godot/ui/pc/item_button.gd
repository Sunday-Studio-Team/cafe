class_name ItemButton
extends TextureButton
## script for the items that show up in the shop
## (which you click on to buy the item)

@export var icon: TextureRect
@export var item_name: RichTextLabel
@export var description: Label

var item: Item


func _ready() -> void:
	icon.texture = item.icon
	item_name.text = "[b]%s [color=gold](%s)" % [item.name, Global.float_to_price(item.price)]
	description.text = item.description

	pressed.connect(
		func():
			if Stats.bank_money >= item.price:
				apply_stats()
				Stats.bank_money -= item.price
				Global.owned_items.append(item)
				queue_free()
	)


func apply_stats():
	if item.stat_bonuses.is_empty():
		push_error("%s has no stat bonuses, can't apply stats" % item.name)
	for stat in item.stat_bonuses:
		var current_stat = Stats.get(stat)
		if current_stat == null:
			push_error("%s is trying to give a bonus to '%s' but that stat does not exist" % [item.name, stat])
		Stats.set(stat, current_stat + item.stat_bonuses[stat])
	for rule in item.rules:
		Global.set(rule, item.rules[rule])
