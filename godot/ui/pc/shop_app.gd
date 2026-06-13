extends PCApp

@export var items_container: Container
@export var item_button_scene: PackedScene
@export var bank_balance: Label

var number_of_items_to_show := 3
var items_in_shop: Array[Item]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	populate_items()


func _physics_process(_delta: float) -> void:
	bank_balance.text = "🏦 bank balance: %s" % Global.float_to_price(Global.bank_money)


func populate_items() -> void:
	# wait for main.gd to clear owned items on restart before populating
	await get_tree().process_frame
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
			var item_button: ItemButton = item_button_scene.instantiate()
			item_button.item = random_item
			items_container.add_child(item_button)
			items_in_shop.append(random_item)
