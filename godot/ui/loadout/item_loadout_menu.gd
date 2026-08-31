extends CanvasLayer

@export var element_scene: PackedScene
@export_category("Nodes")
@export var locker_interactable: Interactable
@export var available_items_container: GridContainer
@export var equipped_items_container: GridContainer
@export var confirm_button: Button

var selected_available_item: Item = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# delete anything we have in the scene for testing first
	for child in available_items_container.get_children():
		child.queue_free()
	for child in equipped_items_container.get_children():
		child.queue_free()

	# TODO: check save for unlocked items instead of just pulling every item
	for item in Global.items:
		add_available_item_button(item)

	# TODO: check save for number of item slots unlocked instead of using
	# hardcoded value
	for i in 3:
		var equipped_item_button: LoadoutMenuElement = element_scene.instantiate()
		equipped_item_button.type = LoadoutMenuElement.Type.EQUIPPED
		equipped_item_button.pressed.connect(
			func():
				_on_equipped_slot_pressed(equipped_item_button)
		)
		equipped_items_container.add_child(equipped_item_button)

	confirm_button.pressed.connect(confirm)
	locker_interactable.interacted.connect(func(): show())


func _physics_process(_delta: float) -> void:
	Global.in_loadout_menu = visible


func _on_available_item_pressed(item_button: LoadoutMenuElement) -> void:
	if item_button.button_pressed:
		for button: Button in available_items_container.get_children():
			if button != item_button:
				button.button_pressed = false
		selected_available_item = item_button.item
	else:
		selected_available_item = null


func _on_equipped_slot_pressed(slot: LoadoutMenuElement) -> void:
	if slot.item:
		add_available_item_button(slot.item)
		slot.item = null

	if selected_available_item:
		for available_item_button: LoadoutMenuElement in available_items_container.get_children():
			if available_item_button.item == selected_available_item:
				available_item_button.queue_free()
		slot.item = selected_available_item
		selected_available_item = null


func add_available_item_button(item: Item) -> void:
	var available_item_button: LoadoutMenuElement = element_scene.instantiate()
	available_item_button.item = item
	available_item_button.type = LoadoutMenuElement.Type.AVAILABE
	available_item_button.pressed.connect(
		func():
			_on_available_item_pressed(available_item_button)
	)
	available_items_container.add_child(available_item_button)


func confirm() -> void:
	var equipped_items: Array[Item]
	
	for equipped_item_button: LoadoutMenuElement in equipped_items_container.get_children():
		if equipped_item_button.item:
			equipped_items.append(equipped_item_button.item)

	Global.owned_items.assign(equipped_items)
	Events.items_updated.emit()

	hide()
