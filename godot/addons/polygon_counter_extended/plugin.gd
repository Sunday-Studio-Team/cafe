@tool
extends EditorPlugin

const _folders_to_check: Array[StringName] = [
	&"res://Assets"
]
const _file_extensions_to_check: Array[StringName] = [
	&"glb"
]

const _dock_scene_path: StringName = &"res://addons/polygon_counter_extended/dock.tscn"

var _dock: PolygonCounterExtendedDock
var _loading_thread: Thread
var _progress_ratio_mutex: Mutex
var _progress_ratio: float
var _results_string: String

func _enter_tree() -> void:
	var dock_scene: PackedScene = load(_dock_scene_path)
	if dock_scene == null:
		push_error("ERROR: Failed to load dock.tscn. Plugin will not function.")
		return
	_dock = dock_scene.instantiate() as PolygonCounterExtendedDock
	if _dock == null:
		push_error("ERROR: Failed to instantiate dock.")
		return

	add_control_to_bottom_panel(_dock, "Polygon Counter Extended")
	_dock.visible = true
	
	_dock.requested_check_all_meshes.connect(_on_dock_requested_check_all_meshes)

func _exit_tree() -> void:	
	if _dock != null and _dock.get_parent() != null:
		remove_control_from_bottom_panel(_dock)
		_dock.queue_free()
		_dock = null


func _on_dock_requested_check_all_meshes() -> void:
	_progress_ratio_mutex = Mutex.new()
	_loading_thread = Thread.new()
	_loading_thread.start(_threaded_check_all_meshes)
	while _loading_thread.is_alive():
		_progress_ratio_mutex.lock()
		_dock.update_progress_bar(_progress_ratio)
		_progress_ratio_mutex.unlock()
		await get_tree().process_frame
	_loading_thread.wait_to_finish()
	_loading_thread = null
	_progress_ratio_mutex = null
	_dock.show_results(_results_string)

func _threaded_check_all_meshes() -> void:
	var file_paths: Array[String] = []
	for folder_path in _folders_to_check:
		var folder_file_paths: Array[String] = _get_all_valid_files_recursively(folder_path)
		file_paths.append_array(folder_file_paths)
	
	var index: int = 0
	var file_polygons_results: Array[FilePolygonsResult] = []
	for file_path in file_paths:
		_progress_ratio_mutex.lock()
		_progress_ratio = float(index) / float(file_paths.size())
		_progress_ratio_mutex.unlock()
		
		var file_polygons_result: FilePolygonsResult = _count_file_polygons(file_path)
		if file_polygons_result == null:
			push_error("ERROR: Couldn't count file polygons for %s" % file_path)
			continue
		file_polygons_results.append(file_polygons_result)
		index += 1
	
	# Sort by poly count
	file_polygons_results.sort_custom(_sort_polygon_count_descending)
	
	var results_string: String = ""
	for file_polygons_result in file_polygons_results:
		results_string += "\"%s\": Polygons: %s, Vertices: %s\n" % [file_polygons_result.file_path, file_polygons_result.polygon_count, file_polygons_result.vertex_count]
	
	_results_string = results_string


func _get_all_valid_files_recursively(folder_path: String) -> Array[String]:
	var file_paths: Array[String] = []
	if not DirAccess.dir_exists_absolute(folder_path):
		push_error("ERROR: Directory %s does not exist." % folder_path)
		return file_paths
	
	var dir_access: DirAccess = DirAccess.open(folder_path)
	if dir_access == null:
		push_error("ERROR: Failed to open directory.")
	
	var subfolder_names: PackedStringArray = dir_access.get_directories()
	for subfolder_name in subfolder_names:
		var subfolder_path: String = "%s/%s" % [folder_path, subfolder_name]
		var subfolder_file_paths: Array[String] = _get_all_valid_files_recursively(subfolder_path)
		file_paths.append_array(subfolder_file_paths)
	
	var folder_file_names: PackedStringArray = dir_access.get_files()
	for folder_file_name in folder_file_names:
		var file_name_extension = folder_file_name.get_extension()
		if file_name_extension not in _file_extensions_to_check:
			continue
		var file_path: String = "%s/%s" % [folder_path, folder_file_name]
		file_paths.append(file_path)
	
	return file_paths

## Returns null if error.
func _count_file_polygons(file_path: String) -> FilePolygonsResult:
	if not file_path.ends_with(".glb"):
		push_error("ERROR: Only .glb is supported for now!")
		return null
	var gltf_document_load: GLTFDocument = GLTFDocument.new()
	var gltf_state_load: GLTFState = GLTFState.new()
	var error: int = gltf_document_load.append_from_file(file_path, gltf_state_load)
	if error != OK:
		push_error("Couldn't load glTF scene (error code: %s)." % error_string(error))
		return null

	var file_vertex_count: int = 0
	var file_polygon_count: int = 0
	
	var gltf_meshes: Array[GLTFMesh] = gltf_state_load.get_meshes()
	for gltf_mesh in gltf_meshes:
		var importer_mesh: ImporterMesh = gltf_mesh.mesh
		var mesh_surface_count: int = importer_mesh.get_surface_count()
		var mesh_vertex_count: int = 0
		var mesh_polygon_count: int = 0
		for surface_index in range(mesh_surface_count):
			var surface_arrays: Array = importer_mesh.get_surface_arrays(surface_index)
			if surface_arrays == null:
				continue
			var vertex_array: Array = surface_arrays[Mesh.ARRAY_VERTEX]
			if vertex_array == null:
				continue
			mesh_vertex_count += vertex_array.size()
			mesh_polygon_count += vertex_array.size() / 3
		file_vertex_count += mesh_vertex_count
		file_polygon_count += mesh_polygon_count

	var file_polygons_result: FilePolygonsResult = FilePolygonsResult.new()
	file_polygons_result.file_path = file_path
	file_polygons_result.polygon_count = file_polygon_count
	file_polygons_result.vertex_count = file_vertex_count
	return file_polygons_result

func _sort_polygon_count_descending(a: FilePolygonsResult, b: FilePolygonsResult) -> bool:
	if a.polygon_count > b.polygon_count:
		return true
	return false

class FilePolygonsResult:
	var file_path: String
	var polygon_count: int
	var vertex_count: int
