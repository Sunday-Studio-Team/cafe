extends Node

# NOTE: i dont think folders are given UIDs so im not sure if theres a way
# to get a ref to a folder that wont break if we move it : (
@export_dir var drinks_folder_path: String
@export var hover_shader: Shader
@export var full_wrong_drink: Drink

var player: Player
var hovered_interactable: Interactable
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var score_update_message: String
var player_in_cctv_los := false
var minigame_active := false


func _ready() -> void:
	drinks.assign(load_resources_from_folder(drinks_folder_path))


func _physics_process(_delta: float) -> void:
	# this has to be reset to false at the start of every frame here
	# because if we set it in the individual security cameras' processes, they
	# would start overriding each other
	player_in_cctv_los = false


func load_resources_from_folder(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource]

	for file_name: String in ResourceLoader.list_directory(folder_path):
		if file_name.ends_with(".tres"):
			resources.append(ResourceLoader.load(folder_path.path_join(file_name)) as Resource)

	return resources


## takes a float, converts it to a string formatted like a price in USD
## [br]e.g. 1.5 -> "$1.50", 10.0 -> "$10"
func float_to_price(number: float) -> String:
	return ("$%.2f" % number).trim_suffix(".00")
