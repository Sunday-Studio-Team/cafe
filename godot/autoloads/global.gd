extends Node

# NOTE: i dont think folders are given UIDs so im not sure if theres a way
# to get a ref to a folder that wont break if we move it : (
@export_dir var drinks_folder_path: String
@export_dir var items_folder_path: String
@export_dir var customer_sprites_folder_path: String
@export var hover_shader: Shader
@export var full_wrong_drink: Drink
@export var star_texture: Texture
@export var half_star_texture: Texture
@export var empty_star_texture: Texture
@export var main_ingredient_icons: Dictionary[Drink.MainIngredient, Texture2D]
@export var liquid_icons: Dictionary[Drink.Liquid, Texture2D]
@export var extra_icons: Dictionary[Drink.Extra, Texture2D]

var player: Player
var hovered_interactable: Interactable:
	get():
		if hovered_interactable == null:
			return
		elif not hovered_interactable.is_inside_tree():
			return null
		else:
			return hovered_interactable
var inspected_shelf_item: ShelfItem
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var items: Array[Item]
var owned_items: Array[Item]
var score_update_message: String
var player_in_cctv_los := false
var minigame_active := false
var in_pc_ui := false
var read_emails: Array[EmailData]
var spam_emails: Array[EmailData]
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
# represented as stars (1 rating = 1 half star)
var employee_rating := 0:
	set(new_value):
		if new_value > 10:
			new_value = 10
		if new_value == employee_rating:
			return

		Events.customer_score_updated.emit(new_value, employee_rating)
		employee_rating = new_value
		if employee_rating < 0:
			employee_rating = 0

		# (see comment for same lines in above func)
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
var holding_make_drink_button := false
var customer_sprites: Array[Texture]
var breakdowns_this_shift := 0
var spills_this_shift := 0
var machines: Array[Machine]
var in_machine_ui: bool = false
var in_ui: bool:
	get():
		if (
				minigame_active
				or in_pc_ui
				or in_machine_ui
		):
			return true
		else:
			return false


func _ready() -> void:
	drinks.assign(load_resources_from_folder(drinks_folder_path))
	items.assign(load_resources_from_folder(items_folder_path))
	customer_sprites.assign(load_resources_from_folder(customer_sprites_folder_path, "png"))


func _physics_process(_delta: float) -> void:
	# this has to be reset to false at the start of every frame here
	# because if we set it in the individual security cameras' processes, they
	# would start overriding each other
	player_in_cctv_los = false
	holding_make_drink_button = false


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
