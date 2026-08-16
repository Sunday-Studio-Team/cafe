extends Node

# NOTE: i dont think folders are given UIDs so im not sure if theres a way
# to get a ref to a folder that wont break if we move it : (
@export_dir var drinks_folder_path: String
@export_dir var items_folder_path: String
@export_dir var ingredients_folder_path: String
@export_dir var customer_sprites_folder_path: String
@export_dir var spill_sprites_path: String
@export var hover_shader: Shader
@export var full_wrong_drink: Drink
@export var star_texture: Texture
@export var half_star_texture: Texture
@export var empty_star_texture: Texture
@export var emails_schedule: Array[EmailData]
@export var complaint_popup: CanvasLayer
@export var special_shifts: Array[SpecialShift]

var popups: Dictionary = { }
var popup_hint_showing: bool = false
var player: Player
var hovered_interactable: Interactable:
	get():
		if hovered_interactable == null:
			return
		elif not hovered_interactable.is_inside_tree():
			return null
		else:
			return hovered_interactable
# max amount of items we can own
var item_slots_amount: int
var inspected_shelf_item: ShelfItem
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var ingredients: Array[Ingredient]
var items: Array[Item]
var owned_items: Array[Item]
var score_update_message: String
var player_in_cctv_los := false
var player_in_cctv_los_camera: SecurityCam3D
var minigame_active := false
var in_spill_minigame := false
var in_pc_ui := false
var read_emails: Array[EmailData]
var spam_emails: Array[EmailData]
var unread_email_count: int
var finished_important_emails: Array[EmailData]
var active_helpdesk_customer: Customer
var holding_ingredients := false
var day := 1
var ai_improvement_enabled := false
var ai_improvement: AIImprovement
var daily_profit := 0.0:
	set(new_value):
		if new_value == daily_profit:
			return

		Events.money_updated.emit(new_value, daily_profit)
		daily_profit = new_value

		# we set this as empty to hopefully avoid anything weird if someone
		# accidentally updates one of these score vars without setting it
		# (like gaining money but seeing a popup like '+1 🙂' from a prev thing)
		# NOTE: i wonder if waiting a frame could ever cause anything weird if
		# we changed a score twice on successive frames D: should get reworked
		# again anyway so hopefully we wont find out .
		await get_tree().process_frame
		score_update_message = ""
# represented as stars (1 rating = 1 half star), max is 10 rating = 5 stars
var employee_rating: int = 0:
	set(new_value):
		if new_value > 10:
			new_value = 10
		if new_value == employee_rating:
			return

		Events.customer_score_updated.emit(new_value, employee_rating)
		employee_rating = new_value
		if employee_rating < 0:
			employee_rating = 0

		# (see ccomment for same lines in above func)
		await get_tree().process_frame
		score_update_message = ""
var bank_money := 0.0
# this just defines the max day where we quit if we beat it
# (instead of loading the next day)
var final_day := 5
# rules (true = rule in effect) (these are toggled per-day in main.gd)
var holding_ingredients_rule := false
# score from refill minigame (to pass to machine)
var refill_minigame_accuracy: float
var making_drink_manually := false
var customer_sprites: Array[Texture]
## the sprites of customers that are in the cafe right now
## (tracked so we dont spawn 2 of the same)
var customer_sprites_spawned: Array[Texture]
var spill_sprites: Array[Texture]
var current_special_shift: SpecialShift
var breakdowns_this_shift := 0
var spills_this_shift := 0
var machines: Array[Machine]
var in_machine_ui: bool = false
var machine_in_use: Machine = null
var in_main_menu := false
var in_end_screen := false
var in_active_item_menu := false
var in_tutorial_screen: bool = false
var in_end_shift_early_menu := false
var in_dialog_screen: bool = false
var in_options_menu: bool = false
var showing_floating_cursor := false
var stamina: float:
	set(new_stam):
		if new_stam > Stats.current.max_stamina:
			new_stam = Stats.current.max_stamina
		if new_stam < 0:
			new_stam = 0

		stamina = new_stam
var sprint_lockout_timer: Timer
# if we save an item in the shop (so that itll show up the next day)
# itll be stored here
var saved_item: Item
var in_ui: bool:
	get():
		if (
				minigame_active
				or in_pc_ui
				or popup_hint_showing
				or in_machine_ui
				or Console.is_visible()
				or in_main_menu
				or in_end_screen
				or in_active_item_menu
				or in_tutorial_screen
				or in_end_shift_early_menu
				or in_dialog_screen
				or in_options_menu
				or showing_floating_cursor
		):
			return true
		else:
			return false
var ordered_drink_to_remake: Drink
# used to decide which items tooltip to show when hovering mouse over tablet
var hovered_item_icon: TabletItemIcon = null
#Active Items
var equipped_item: Item = null
#tutorial flags
var tutorial_refill_shown: bool = false #on day 1, shows a tutorial when a machine runs out of food
var tutorial_go_clean_spill_shown: bool = false #on day 1, shows a tutorial the first time a spill happens.
var tutorial_show_camera: bool = false #on day 2, shows a tutorial; player needs to avoid running under cameras.


func _ready() -> void:
	drinks.assign(load_resources_from_folder(drinks_folder_path))
	for drink in drinks:
		drink.create() # adds the price and creates the typing minigame resource
	items.assign(load_resources_from_folder(items_folder_path))
	ingredients.assign(load_resources_from_folder(ingredients_folder_path))
	customer_sprites.assign(load_resources_from_folder(customer_sprites_folder_path, "png"))
	spill_sprites.assign(load_resources_from_folder(spill_sprites_path, "png"))


func _process(_delta: float) -> void:
	# this has to be reset to false at the start of every frame here
	# because if we set it in the individual security cameras' processes, they
	# would start overriding each other
	player_in_cctv_los = false
	making_drink_manually = false

	if in_ui or get_tree().paused:
		if Global.minigame_active and in_spill_minigame:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func load_resources_from_folder(path: String, extension: String = "tres") -> Array[Resource]:
	var resources: Array[Resource]

	for file_name: String in ResourceLoader.list_directory(path):
		if file_name.ends_with(extension):
			resources.append(ResourceLoader.load(path.path_join(file_name)) as Resource)

	return resources


## takes a float, converts it to a string formatted like a price in USD
## [br]e.g. 1.5 -> "$1.50", 10.0 -> "$10"
func float_to_price(number: float) -> String:
	return ("$%.2f" % number).trim_suffix(".00")


#Equips the item:
func equip_item(item: Item):
	equipped_item = item
	if item == null:
		Events.emit_signal("play_viewmodel_animation", "default")
		return

	if item.name == "hammer":
		Events.emit_signal("play_viewmodel_animation", "hammer_equip")

	else:
		Events.emit_signal("play_viewmodel_animation", "default")


func refresh_active_items():
	for item in owned_items:
		item.can_be_used = true
	Events.items_updated.emit()


func deactivate_active_item(target_item: Item):
	Global.equipped_item = null
	for item in owned_items:
		if item.name == target_item.name:
			item.can_be_used = false
			Events.items_updated.emit()
