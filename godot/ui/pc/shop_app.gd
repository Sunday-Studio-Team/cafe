extends PCApp

@export var items_container: Container
@export var item_button_scene: PackedScene
@export var bank_balance: RichTextLabel
@export var cant_buy_sound: AudioStreamPlayer
@export var bought_sound: AudioStreamPlayer
@export var reroll_sound: AudioStreamPlayer
@export var cant_reroll_sound: AudioStreamPlayer
@export var reroll_button: Button

var number_of_items_to_show := 3
var items_in_shop: Array[Item]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	populate_items()
	reroll_button.text = "re-roll (%s)" % Global.float_to_price(Stats.current.cost_to_reroll)
	reroll_button.pressed.connect(_on_reroll_pressed)


func _physics_process(_delta: float) -> void:
	super(_delta)

	bank_balance.text = "🏦 bank balance: [color=gold]%s[/color]" % Global.float_to_price(Global.bank_money)


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
			item_button.clicked.connect(_on_item_button_clicked)


func _on_reroll_pressed() -> void:
	if not Global.bank_money >= Stats.current.cost_to_reroll:
		cant_reroll_sound.play()
		var t := create_tween().set_parallel()
		t.tween_property(reroll_button, "modulate", Color.WHITE, 1).from(Color.RED)
		t.tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.RED)
		return

	for itm in items_container.get_children():
		itm.queue_free()
	populate_items()
	Global.bank_money -= Stats.current.cost_to_reroll
	reroll_button.hide()
	reroll_sound.play()


func _on_item_button_clicked(bought: bool) -> void:
	if bought:
		create_tween().tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.GOLD)
		bought_sound.play()
		reroll_button.hide()
	else:
		create_tween().tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.RED)
		cant_buy_sound.play()
