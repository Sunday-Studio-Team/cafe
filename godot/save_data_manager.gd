extends Node

const _options_file_path: StringName = &"user://game_options_data.tres"

@export_dir var _save_file_path: String

var _options_data: OptionsData
var save_data: SaveData


func _ready() -> void:
	load_options_data_from_file()
	_options_data.apply_options()

	load_save_data()


func get_options_data() -> OptionsData:
	return _options_data


func load_options_data_from_file() -> void:
	var options_data: OptionsData = null
	if FileAccess.file_exists(_options_file_path):
		var saved_resource: Resource = ResourceLoader.load(_options_file_path)
		options_data = (saved_resource as OptionsData)
	if options_data == null:
		options_data = OptionsData.new()
		print("Creating new options data.")
	else:
		print("Loaded existing options file.")
	
	if options_data.options_version != options_data.LATEST_OPTIONS_VERSION:
		options_data.update_version()
	_options_data = options_data


func load_save_data() -> void:
	if FileAccess.file_exists(_save_file_path):
		save_data = ResourceLoader.load(_save_file_path)

	if save_data == null:
		save_data = SaveData.new()
		print("Creating new save file.")
	else:
		print("Loaded existing save file.")


func wipe_save() -> void:
	save_data = SaveData.new()
	save_game()


func save_options_data_to_file() -> void:
	ResourceSaver.save(_options_data, _options_file_path)
	print("Saved options file.")


func save_game() -> void:
	ResourceSaver.save(save_data, _save_file_path)
	print("Saved game.")
