class_name ShopApp
extends PCApp

@export var items_container: Container
@export var item_button_scene: PackedScene
@export var bank_balance: RichTextLabel
@export var cant_buy_sound: AudioStreamPlayer
@export var bought_sound: AudioStreamPlayer
@export var reroll_sound: AudioStreamPlayer
@export var cant_reroll_sound: AudioStreamPlayer
@export var reroll_button: Button
@export var shelf_full_warning: Control

var number_of_items_to_show := 3
var items_in_shop: Array[Item]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	populate_items()
	reroll_button.text = "re-roll (%s)" % Global.float_to_price(Stats.current.cost_to_reroll)
	reroll_button.pressed.connect(_on_reroll_pressed)
	reroll_button.mouse_entered.connect(
		func():
			create_tween().tween_property(reroll_button, "offset_transform_scale", Vector2.ONE * 1.1, 0.25)
	)
	reroll_button.mouse_exited.connect(
		func():
			create_tween().tween_property(reroll_button, "offset_transform_scale", Vector2.ONE, 0.25)
	)


func _physics_process(_delta: float) -> void:
	super(_delta)

	bank_balance.text = "🏦 bank balance: [color=gold]%s[/color]" % Global.float_to_price(Global.bank_money)

## Gives the requested number of items randomly, from the pool of items currently unowned by the player.
## If requested_num_items <= the remaining unowned items, it will give all the remaining items,
## which may be less than the requested number.
static func get_random_unowned_items(requested_num_items: int) -> Array[Item]:
	var remaining_unowned_items: Array[Item] = []
	for item in Global.items:
		if Global.owned_items.has(item):
			continue
		remaining_unowned_items.append(item)
	
	var random_unowned_items: Array[Item] = []
	for i in requested_num_items:
		if remaining_unowned_items.size() == 0:
			break
		var random_index: int = randi_range(0, remaining_unowned_items.size()-1)
		var random_unowned_item: Item = remaining_unowned_items[random_index]
		random_unowned_items.append(random_unowned_item)
		remaining_unowned_items.remove_at(random_index)
	
	return random_unowned_items

static func own_and_apply_item(item: Item) -> void:
	item.apply_stats()
	Global.owned_items.append(item)
	Events.items_updated.emit()

func populate_items() -> void:
	# wait for main.gd to clear owned items on restart before populating
	await get_tree().process_frame
	
	var items_to_show: Array[Item] = get_random_unowned_items(number_of_items_to_show)
	for item in items_to_show:
		var item_button: ItemButton = item_button_scene.instantiate()
		item_button.item = item
		items_container.add_child(item_button)
		items_in_shop.append(item)
		item_button.item_button_pressed.connect(_on_item_button_pressed)	

func _on_reroll_pressed() -> void:
	if not Global.bank_money >= Stats.current.cost_to_reroll:
		cant_reroll_sound.play()
		var t := create_tween().set_parallel()
		t.tween_property(reroll_button, "modulate", Color.WHITE, 1).from(Color.RED)
		t.tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.RED)
		return

	reroll_button.disabled = true
	reroll_sound.play()

	await create_tween().tween_property(
		reroll_button,
		"offset_transform_rotation",
		deg_to_rad(360),
		0.5,
	).set_trans(Tween.TRANS_SPRING).finished

	for itm in items_container.get_children():
		itm.queue_free()
	populate_items()
	Global.bank_money -= Stats.current.cost_to_reroll
	reroll_button.hide()


func _on_item_button_pressed(item_button: ItemButton) -> void:	
	var item: Item = item_button.item
	var can_afford: bool = Global.bank_money >= item.price
	var has_free_item_slots: bool = Global.owned_items.size() < Global.item_slots_amount
	var did_buy_item: bool = can_afford and has_free_item_slots
	item_button.notify_pressed(did_buy_item)
	if did_buy_item:
		Global.bank_money -= item.price
		
		own_and_apply_item(item)
		
		item_button.queue_free()
		create_tween().tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.GOLD)
		bought_sound.play()
		reroll_button.hide()
	else:
		cant_buy_sound.play()
		if has_free_item_slots:
			create_tween().tween_property(bank_balance, "modulate", Color.WHITE, 1.0).from(Color.RED)
		else:
			shelf_full_warning.show()
			await get_tree().create_timer(0.5, false).timeout
			shelf_full_warning.hide()
