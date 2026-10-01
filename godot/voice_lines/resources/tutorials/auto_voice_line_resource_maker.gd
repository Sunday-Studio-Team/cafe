@tool
class_name AutoVoiceLineResourceMaker
extends Resource

@export_dir var create_vl_resources_input_folder_path: String
@export_dir var create_vl_resources_output_folder_path: String
@export var create_vl_resources_set_speaker_resource: VoiceLineSpeaker
@export_tool_button("Create Voice Line Resources", "Callable") var create_vl_resources_action: Callable = _create_vl_resources

func _create_vl_resources() -> void:
	var dir_access: DirAccess = DirAccess.open(create_vl_resources_input_folder_path)
	var dir_file_names: PackedStringArray = dir_access.get_files()
	for dir_file_name in dir_file_names:
		var file_path: String = "%s%s" % [create_vl_resources_input_folder_path, dir_file_name]
		
		# Filter only the .wav files
		const wav_suffix: String = ".wav"
		if !file_path.ends_with(wav_suffix):
			continue
		print("file_path: %s" % file_path)

		var new_voice_line: VoiceLine = VoiceLine.new()

		var voice_line_id: String = dir_file_name.split(".")[0]
		new_voice_line.voice_line_id = voice_line_id

		new_voice_line.audio_stream = ResourceLoader.load(file_path)
		
		new_voice_line.speaker = create_vl_resources_set_speaker_resource
		
		var save_file_path: String = "%s%s.tres" % [create_vl_resources_output_folder_path, voice_line_id]
		ResourceSaver.save(new_voice_line, save_file_path)
		
		notify_property_list_changed()
		print("save_file_path: %s" % save_file_path)
		
