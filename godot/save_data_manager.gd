extends Node

const _options_file_path: StringName = &"user://game_options_data.tres"

var _options_data: OptionsData

func _ready() -> void:
	load_options_data_from_file()
	_options_data.apply_options()

func get_options_data() -> OptionsData:
	return _options_data

func load_options_data_from_file() -> void:
	var options_data: OptionsData = null
	if FileAccess.file_exists(_options_file_path):
		var saved_resource: Resource = ResourceLoader.load(_options_file_path)
		options_data = (saved_resource as OptionsData)
	if options_data == null:
		options_data = OptionsData.new()
		print("Creating new options file.")
	else:
		print("Loaded existing options file.")
	_options_data = options_data

func save_options_data_to_file() -> void:
	ResourceSaver.save(_options_data, _options_file_path)
	print("Saved options file.")
