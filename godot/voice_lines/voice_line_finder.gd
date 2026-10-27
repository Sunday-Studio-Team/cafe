## this is for searching voice lines .
## if you put in some text, itll print voice lines containing that text !
@tool
extends Node

@export_dir var voice_lines_folders: Array[String]
@export var text_to_search: String
@export_tool_button("search for line") var search_action: Callable = search


func search() -> void:
	print("----------")

	print("searching for lines containing \"%s\" . . ." % text_to_search)

	var all_voice_lines: Array[Resource]

	for folder in voice_lines_folders:
		for line in load_resources_from_folder(folder):
			all_voice_lines.append(line)

	var found_any := false

	for line: VoiceLine in all_voice_lines:
		if line.subtitle_en.containsn(text_to_search):
			print("found line %s - full text: %s" % [line.voice_line_id, line.subtitle_en])
			found_any = true

	if not found_any:
		print("didnt find any .")

	text_to_search = ""
	print("----------")


## this is just the function from global.gd copied here so it can run when global doesnt exist while game aint running
## NOTE: tried making that a static func so it would work without doing this but that didnt work .
func load_resources_from_folder(path: String, extension: String="tres") -> Array[Resource]:
	var resources: Array[Resource]

	for file_name: String in ResourceLoader.list_directory(path):
		if file_name.ends_with(extension):
			resources.append(ResourceLoader.load(path.path_join(file_name)) as Resource)

	return resources
