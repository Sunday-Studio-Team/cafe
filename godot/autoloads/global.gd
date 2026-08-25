extends Node

# NOTE: i dont think folders are given UIDs so im not sure if theres a way
# to get a ref to a folder that wont break if we move it : (
@export_dir var drinks_folder_path: String
@export_dir var items_folder_path: String
@export_dir var ingredients_folder_path: String
@export_dir var customer_sprites_folder_path: String
@export_dir var review_folder_path: String
@export_dir var spill_sprites_path: String
@export_dir var tippy_voice_path: String
@export var hover_shader: Shader
@export var full_wrong_drink: Drink
@export var star_texture: Texture
@export var half_star_texture: Texture
@export var empty_star_texture: Texture
@export var emails_schedule: Array[EmailData]
@export var complaint_popup: CanvasLayer
var popups: Dictionary = {}
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
var main_scene: Main
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var ingredients: Array[Ingredient]
var items: Array[Item]
var reviews: Array[Review]
var owned_items: Array[Item]
var score_update_message: String
var player_in_cctv_los := false
var minigame_active := false:
	set(value):
		minigame_active = value
		if minigame_active == false:
			current_minigame_name = ""
var current_minigame_name: String
var in_spill_minigame := false
var in_pc_ui := false
var read_emails: Array[EmailData]
var spam_emails: Array[EmailData]
var unread_email_count: int
var finished_important_emails: Array[EmailData]
var active_help_desk_customer: Customer
var holding_ingredients := false
var day := 0
var shift_length: float
var shift_time_remaining: float
var shift_progress_ratio: float
var ai_improvement_enabled := false
var ai_improvement: AIImprovement
var daily_cafe_money := 0.0:
	set(new_value):
		if new_value == daily_cafe_money:
			return

		Events.money_updated.emit(new_value, daily_cafe_money)
		daily_cafe_money = new_value

		# we set this as empty to hopefully avoid anything weird if someone
		# accidentally updates one of these score vars without setting it
		# (like gaining money but seeing a popup like '+1 🙂' from a prev thing)
		# NOTE: i wonder if waiting a frame could ever cause anything weird if
		# we changed a score twice on successive frames D: should get reworked
		# again anyway so hopefully we wont find out .
		await get_tree().process_frame
		score_update_message = ""
# represented as stars (1 rating = 1 star.)
var employee_rating: float = 0:
	set(new_value):
		if new_value > Stats.current.employee_rating_max:
			new_value = Stats.current.employee_rating_max
		if new_value < 0.0:
			new_value = 0.0
		if new_value == employee_rating:
			return
		
		var previous_employee_rating: float = employee_rating
		employee_rating = new_value
		Events.employee_rating_updated.emit(new_value, previous_employee_rating)

		# (see comment for same lines in above func)
		await get_tree().process_frame
		score_update_message = ""
var machine_customer_flow_rate: float
var help_desk_customer_flow_rate: float
var player_tips_bank := 0.0
# this just defines the max day where we quit if we beat it
# (instead of loading the next day)
var final_day := 5
# score from refill minigame (to pass to machine)
var refill_minigame_accuracy: float
var making_drink_manually := false
var customer_sprites: Array[Texture]
## the sprites of customers that are in the cafe right now
var customer_sprites_in_use: Array[Texture]
var spill_sprites: Array[Texture]
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
var in_tutorial_selection := false
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
				or in_tutorial_selection
		):
			return true
		else:
			return false
# Remaking drink variables --
var ordered_drink_to_remake: Drink
var ordered_drink_customer: Customer
# End remaking drink variables --
# used to decide which items tooltip to show when hovering mouse over tablet
var hovered_item_icon: TabletItemIcon = null
#Active Items
var equipped_item: Item = null
# Tutorial flags
var tutorial_machine_used: bool = false
var tutorial_drink_accepted: bool = false
var tutorial_remake_button_pressed: bool = false
var tutorial_drink_remade: bool = false
var tutorial_ingredients_bag_got: bool = false
var tutorial_refill_shown: bool = false #on day 1, shows a tutorial when a machine runs out of food
var tutorial_go_clean_spill_shown: bool = false #on day 1, shows a tutorial the first time a spill happens.
var tutorial_show_camera: bool = false #on day 2, shows a tutorial; player needs to avoid running under cameras.
var shift_started: bool = false
# Voice Line System
var voice_line_system: VoiceLineSystem


func _ready() -> void:
	if SaveDataManager.save_data.finished_or_skipped_tutorial:
		day = 1
	if OS.has_feature("tutorial"):
		day = 0

	drinks.assign(load_resources_from_folder(drinks_folder_path))
	for drink in drinks:
		drink.create() # adds the price and creates the typing minigame resource
	items.assign(load_resources_from_folder(items_folder_path))
	ingredients.assign(load_resources_from_folder(ingredients_folder_path))
	reviews.assign(load_resources_from_folder(review_folder_path))
	customer_sprites.assign(load_resources_from_folder(customer_sprites_folder_path, "png"))
	spill_sprites.assign(load_resources_from_folder(spill_sprites_path, "png"))


# NOTE: these things in physics process instead of process for timing reasons
func _physics_process(_delta: float) -> void:
	# this have to be reset to false at the start of every frame here
	# because if we set it in the individual security cameras' processes, they
	# would start overriding each other
	player_in_cctv_los = false

	making_drink_manually = current_minigame_name == "Captcha"


func _process(_delta: float) -> void:
	if in_ui or get_tree().paused:
		if in_spill_minigame:
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

	if item.item_id == "hammer":
		Events.emit_signal("play_viewmodel_animation", "hammer_equip")

	else:
		Events.emit_signal("play_viewmodel_animation", "default")


func refresh_active_items():
	for item in owned_items:
		item.can_be_used = true
	Events.items_updated.emit()


func put_active_item_on_cooldown(target_item: Item):
	target_item.active_item_remaining_cooldown = target_item.active_item_cooldown_at_levels[target_item.item_level]
	target_item.can_be_used = false


func day_to_string(d: int) -> String:
	var days_as_strings: Dictionary = {
		0: "Friday",
		1: "Monday",
		2: "Tuesday",
		3: "Wednesday",
		4: "Thursday",
	}

	var day_as_string: String = days_as_strings[d % 5]

	if d == 0:
		day_as_string = "TRAINING"

	return day_as_string
