extends PCApp

@export var items_container: Container
@export var bank_balance: Label

var number_of_items_to_show := 3
var items_in_shop: Array[Item]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	populate_items()


func _physics_process(_delta: float) -> void:
	bank_balance.text = "🏦 bank balance: %s" % Global.float_to_price(Stats.bank_money)


func populate_items() -> void:
	var random_item: Item = null
	# we track this in case something goes wrong here with finding the items
	# and we dont get the game stuck in an infinite loop
	var loops := 0
	var valid_item := true
	for slot in number_of_items_to_show:
		while (
			random_item == null
			or items_in_shop.has(random_item)
			or Global.owned_items.has(random_item)
		):
			random_item = Global.items.pick_random()
			loops += 1
			if loops >= 50:
				valid_item = false
				push_error("not enough valid items to populate shop")
				break

		if valid_item:
			var item_button := ItemButton.new()
			item_button.item = random_item
			items_container.add_child(item_button)
			items_in_shop.append(random_item)


class ItemButton extends Button:
	var item: Item


	func _ready() -> void:
		pressed.connect(
			func():
				if Stats.bank_money >= item.price:
					apply_stats()
					Stats.bank_money -= item.price
					Global.owned_items.append(item)
					queue_free()
		)

		text = "%s (%s)" % [item.name, Global.float_to_price(item.price)]
		icon = item.icon


	func apply_stats():
		for stat in item.stat_bonuses:
			var current_stat = Stats.get(stat)
			Stats.set(stat, current_stat + item.stat_bonuses[stat])
		for rule in item.rules:
			Global.set(rule, item.rules[rule])
