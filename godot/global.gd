extends Node

# NOTE: i dont think folders are given UIDs so im not sure if theres a way
# to get a ref to a folder that wont break if we move it : (
@export_dir var drinks_folder_path: String

@export var hover_shader : Shader

var player: Player
var hovered_interactable: Interactable
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var score: int = 0
var goal_score: int = 10


func _ready() -> void:
	drinks.assign(load_resources_from_folder(drinks_folder_path))


func load_resources_from_folder(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource]

	var dir := DirAccess.open(folder_path)

	for file_name: String in dir.get_files():
		if file_name.ends_with(".tres"):
			resources.append(load(folder_path.path_join(file_name)) as Resource)

	return resources
