extends CanvasLayer

@export var element_scene: PackedScene
@export_category("Nodes")
@export var root: Control
@export var locker_interactable: Interactable
@export var available_items_container: GridContainer
@export var equipped_items_container: GridContainer
@export var confirm_button: Button
# NOTE: OMG i never made this thing its own class cos it was only being used in
# 1-2 places but ive had to redo it more times than i expected and its kind of
# tedious . 0_0
@export var item_hover_tooltip: Control
@export var item_hover_tooltip_name: RichTextLabel
@export var item_hover_tooltip_description: RichTextLabel
@export var item_hover_tooltip_cooldown_label: RichTextLabel
@export var item_hover_tooltip_passive_indicator: Control
@export var item_hover_tooltip_active_indicator: Control

var selected_available_item: Item = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirm_button.pressed.connect(confirm_and_hide)
	locker_interactable.interacted.connect(func(): show())
	visibility_changed.connect(
		func():
			if visible:
				var t := create_tween().set_parallel()
				t.tween_property(root, "offset_transform_scale", Vector2.ONE, 0.1).from(Vector2.ZERO)
				t.tween_property(root, "offset_transform_position_ratio:y", 0, 0.1).from(0.25)
				populate()
	)


func populate() -> void:
	# delete anything we have in the scene for testing/from prev uses first
	for child in available_items_container.get_children():
		child.queue_free()
	for child in equipped_items_container.get_children():
		child.queue_free()

	# TODO: check save for unlocked items instead of just pulling every item
	for item in Global.items:
		if not Global.owned_items.has(item):
			add_available_item_button(item)

	# TODO: check save for number of item slots unlocked instead of using
	# hardcoded value
	for i in Global.day:
		var equipped_item_button: LoadoutMenuElement = element_scene.instantiate()
		if Global.owned_items.size() >= i + 1:
			equipped_item_button.item = Global.owned_items[i]
		equipped_item_button.pressed.connect(
			func():
				_on_equipped_slot_pressed(equipped_item_button)
		)
		equipped_items_container.add_child(equipped_item_button)


func _physics_process(_delta: float) -> void:
	Global.in_loadout_menu = visible

	if Input.is_action_just_pressed("pause"):
		confirm_and_hide()

	handle_item_hover_tooltip()


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
	available_item_button.toggle_mode = true
	available_item_button.pressed.connect(
		func():
			_on_available_item_pressed(available_item_button)
	)
	available_items_container.add_child(available_item_button)


func confirm_and_hide() -> void:
	var equipped_items: Array[Item]

	for equipped_item_button: LoadoutMenuElement in equipped_items_container.get_children():
		if equipped_item_button.item:
			equipped_items.append(equipped_item_button.item)

	Global.owned_items.assign(equipped_items)
	Events.items_updated.emit()

	selected_available_item = null

	var t := create_tween()
	t.tween_property(root, "offset_transform_scale", Vector2.ZERO, 0.1)
	t.tween_property(root, "offset_transform_position_ratio:y", 0.25, 0.1)
	await t.finished
	hide()


func handle_item_hover_tooltip() -> void:
	item_hover_tooltip.position = get_viewport().get_mouse_position()

	var hovered_element: LoadoutMenuElement = Global.hovered_loadout_menu_element

	if hovered_element != null:
		var item: Item = hovered_element.item
		if not item == null:
			item_hover_tooltip_name.text = "[b]%s Lv%s[/b]" % [item.name, item.item_level]
			item_hover_tooltip_description.text = item.description_at_levels[item.item_level]
			if item.is_active_item:
				item_hover_tooltip_passive_indicator.hide()
				item_hover_tooltip_active_indicator.show()
				item_hover_tooltip_cooldown_label.text = "(%ss cooldown)" % item.active_item_cooldown_at_levels[item.item_level]
			else:
				item_hover_tooltip_passive_indicator.show()
				item_hover_tooltip_active_indicator.hide()

	item_hover_tooltip.visible = (
			hovered_element != null and hovered_element.item != null
			and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	)
