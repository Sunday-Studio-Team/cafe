class_name ItemLoadoutMenu
extends CanvasLayer

# (B AND C DISABLED CUZ THEY CLIP INTO STUFF)
const LOCKER_ANIMATION_NAMES: Array[String] = [
	"idle_notice_me_a",
	#"idle_notice_me_b",
	#"idle_notice_me_c"
]

@export var element_scene: PackedScene
@export_category("Nodes")
@export var root: Control

@export var available_items_container: GridContainer
@export var equipped_items_container: GridContainer
@export var confirm_button: Button
@export var locker_open_sound: AudioStreamPlayer
@export var locker_close_sound: AudioStreamPlayer
@export var item_hover_tooltip: ItemHoverTooltip

var locker_interactable: Interactable
var locker_model: ItemLockerModel
var locker_animation_player: AnimationPlayer
var player_has_confirmed_loadout_at_least_once := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

	Global.item_loadout_menu = self

	locker_interactable = Global.item_locker.interactable
	locker_model = Global.item_locker.item_locker_model
	locker_animation_player = Global.item_locker.animation_player

	Global.player_ui_sub_viewport_container.allow_input_changed.connect(_on_player_ui_sub_viewport_container_allow_input_changed)
	confirm_button.pressed.connect(confirm_and_hide_menu)
	locker_interactable.interacted.connect(
			func():
				Global.tutorial_day_2_locker_opened = true
				show()
	)
	visibility_changed.connect(
			func():
				if visible:
					locker_animation_player.stop()
					root.offset_transform_scale = Vector2.ZERO
					locker_open_sound.play()
					await locker_model.open_door()
					var t := create_tween().set_parallel()
					t.tween_property(root, "offset_transform_scale", Vector2.ONE, 0.1).from(Vector2.ZERO)
					t.tween_property(root, "offset_transform_position_ratio:y", 0, 0.1).from(0.25)
					populate()
				else:
					locker_model.close_door()
					locker_close_sound.play()
	)
	locker_animation_player.animation_finished.connect(
		func(_animation: StringName) -> void:
				await get_tree().create_timer(5, false).timeout
				if not (
					player_has_confirmed_loadout_at_least_once
					or Global.in_loadout_menu
					or Global.playing_tutorial
				):
					locker_animation_player.play(LOCKER_ANIMATION_NAMES.pick_random())
	)
	await get_tree().create_timer(10, false).timeout
	if not (
		player_has_confirmed_loadout_at_least_once
		or Global.in_loadout_menu
		or Global.playing_tutorial
	):
		locker_animation_player.play(LOCKER_ANIMATION_NAMES.pick_random())


func populate() -> void:
	# delete anything we have in the scene for testing/from prev uses first
	for child in available_items_container.get_children():
		child.queue_free()
	for child in equipped_items_container.get_children():
		child.queue_free()

	# if we dont wait here for the children to free, we'll get the wrong values when we try to rezise the grids
	await get_tree().process_frame

	for item in Global.unlocked_items:
		if not Global.owned_items.has(item):
			add_available_item_button(item)

	for i in SaveDataManager.save_data.latest_unlocked_day:
		var equipped_item_button: LoadoutMenuElement = element_scene.instantiate()
		if Global.owned_items.size() >= i + 1:
			equipped_item_button.item = Global.owned_items[i]
		equipped_item_button.pressed.connect(
				func():
					_on_equipped_slot_pressed(equipped_item_button)
		)
		equipped_item_button.is_equipped_slot = true
		equipped_items_container.add_child(equipped_item_button)

	resize_grids()


func resize_grids() -> void:
	var num_of_available_items := available_items_container.get_children().size()
	if num_of_available_items % 3 == 0 and num_of_available_items < 9:
		available_items_container.columns = 3
	elif num_of_available_items % 4 == 0:
		available_items_container.columns = 4
	else:
		available_items_container.columns = 6

	var num_of_equipped_item_slots := equipped_items_container.get_children().size()
	if num_of_equipped_item_slots % 3 == 0 and num_of_equipped_item_slots < 9:
		equipped_items_container.columns = 3
	elif num_of_available_items % 4 == 0:
		equipped_items_container.columns = 4
	else:
		equipped_items_container.columns = 5


func _physics_process(_delta: float) -> void:
	Global.in_loadout_menu = visible

	if visible:
		handle_item_hover_tooltip()


func _on_available_item_pressed(item_button: LoadoutMenuElement) -> void:
	var item_to_equip: Item = item_button.item

	item_button.queue_free()

	var equipped_slot_to_fill: LoadoutMenuElement
	var potential_slots: Array[Node] = equipped_items_container.get_children()
	for slot: LoadoutMenuElement in potential_slots:
		if slot.item == null:
			equipped_slot_to_fill = slot
			break

	if equipped_slot_to_fill == null:
		equipped_slot_to_fill = potential_slots.back()

	if equipped_slot_to_fill.item != null:
		add_available_item_button(equipped_slot_to_fill.item)

	equipped_slot_to_fill.item = item_to_equip

	resize_grids()


func _on_equipped_slot_pressed(slot: LoadoutMenuElement) -> void:
	if slot.item:
		add_available_item_button(slot.item)
		slot.item = null


func add_available_item_button(item: Item) -> void:
	var available_item_button: LoadoutMenuElement = element_scene.instantiate()
	available_item_button.item = item
	available_item_button.pressed.connect(
			func():
				_on_available_item_pressed(available_item_button)
	)
	available_items_container.add_child(available_item_button)
	resize_grids()


func confirm_and_hide_menu() -> void:
	Global.tutorial_day_2_locker_loadout_confirmed = true

	# this is what triggers the door to open
	# we only want it to trigger once
	if not player_has_confirmed_loadout_at_least_once:
		Events.player_confirmed_item_loadout.emit()
		player_has_confirmed_loadout_at_least_once = true

	var equipped_items: Array[Item]

	for equipped_item_button: LoadoutMenuElement in equipped_items_container.get_children():
		if equipped_item_button.item:
			equipped_items.append(equipped_item_button.item)

	# unapply existing items
	for item in Global.owned_items:
		item.unapply_stats()

	Global.owned_items.assign(equipped_items)

	SaveDataManager.save_data.equipped_item_ids.clear()
	for item in Global.owned_items:
		SaveDataManager.save_data.equipped_item_ids.append(item.item_id)
	SaveDataManager.save_game_to_file()

	# apply new items
	for item in Global.owned_items:
		item.apply_stats()

	Events.items_updated.emit()

	var t := create_tween()
	t.tween_property(root, "offset_transform_scale", Vector2.ZERO, 0.1)
	t.tween_property(root, "offset_transform_position_ratio:y", 0.25, 0.1)
	await t.finished
	hide()


func handle_item_hover_tooltip() -> void:
	var hovered_element: LoadoutMenuElement = Global.hovered_loadout_menu_element

	if hovered_element == null:
		item_hover_tooltip.item = null
	else:
		item_hover_tooltip.item = hovered_element.item


# called when we're dragging an element and we let go on top of another
func drop_dragged_element(item: Item, source_slot: LoadoutMenuElement, target_slot: LoadoutMenuElement) -> void:
	var previous_item_in_target_slot: Item = target_slot.item
	target_slot.item = item

	if source_slot.is_equipped_slot:
		source_slot.item = previous_item_in_target_slot
	else:
		if previous_item_in_target_slot != null:
			add_available_item_button(previous_item_in_target_slot)
		source_slot.queue_free()

func _on_player_ui_sub_viewport_container_allow_input_changed(allow_input: bool) -> void:
	if allow_input:
		root.mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED
	else:
		root.mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED
