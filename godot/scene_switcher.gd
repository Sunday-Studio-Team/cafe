class_name SceneSwitcher
extends Node

enum GameScene {
	MAIN_SCENE,
	MAIN_MENU,
	END_OF_DAY_DIALOG_SCENE,
}

const LOADING_FADE_IN_TIME := 0.5
const LOADING_FADE_OUT_TIME := 1.0

@export var loading_screen: ColorRect
@export var _loading_progress_bar: ProgressBar
@export var loading_icons: Control
@export var _main_scene_uid: StringName
@export var _main_menu_uid: StringName
@export var _end_of_day_dialog_scene_uid: StringName
## Additional resources to always keep cached for speed. 
@export var _main_sub_resource_uids: Array[StringName]

var current_scene: Node = null
var loading_tween: Tween

# Caching for quick loads
var _cached_main_packed_scene: PackedScene
var _cached_sub_resources: Dictionary[StringName, Resource]

func _ready() -> void:
	Events.scene_switch_requested.connect(load_scene)
	Events.quit_game_requested.connect(quit_game)
	
	if OS.has_feature("editor"):
		load_scene(SceneSwitcher.GameScene.MAIN_SCENE)
	else:
		load_scene(SceneSwitcher.GameScene.MAIN_MENU)


func _process(_delta: float) -> void:
	loading_icons.visible = loading_screen.modulate.a == 1


func load_scene(scene: SceneSwitcher.GameScene) -> void:
	const TIMING_PRINTS: bool = true
	
	if current_scene:
		get_tree().paused = true
		loading_tween = create_tween()
		loading_tween.tween_property(loading_screen, "modulate:a", 1, LOADING_FADE_IN_TIME).from(0)
		await loading_tween.finished
		current_scene.queue_free()
		await current_scene.tree_exited

	_loading_progress_bar.visible = true
	_loading_progress_bar.min_value = 0.0
	_loading_progress_bar.max_value = 1.0

	var loading_start_time_ms: int = Time.get_ticks_msec()
	if TIMING_PRINTS: print("SceneSwitcher: started timing loading")
	
	var cached_packed_scene: PackedScene = null
	if scene == SceneSwitcher.GameScene.MAIN_SCENE:
		if _cached_main_packed_scene != null:
			cached_packed_scene = _cached_main_packed_scene

	var scene_packed_scene: PackedScene = null
	if cached_packed_scene != null:
		scene_packed_scene = cached_packed_scene
		if TIMING_PRINTS: print("SceneSwitcher: getting scene from cache")
	else:
		var scene_uid: StringName = _scene_enum_to_uid(scene)
		
		var resource_uid_requests: Array[StringName] = []
		if scene == SceneSwitcher.GameScene.MAIN_SCENE:
			resource_uid_requests.append_array(_main_sub_resource_uids)
		resource_uid_requests.append(scene_uid)
		
		var finished_requests: int = 0
		for resource_uid_request in resource_uid_requests:
			var request_start_time_ms: int = Time.get_ticks_msec()
			if TIMING_PRINTS: print("SceneSwitcher: started timing resource %s loading" % finished_requests)
			
			var use_sub_threads: bool = false
			if resource_uid_request in _main_sub_resource_uids:
				if TIMING_PRINTS: print("SceneSwitcher: loading sub resource without threads")
				use_sub_threads = false
			else:
				if TIMING_PRINTS: print("SceneSwitcher: loading the main requested scene")
				# WARNING: If set to true for the main scene, causes errors in the debugger:
					# E 0:00:02:675   get_script: /root/Global: The caller thread can't call the function `get_script()` on this node. Use `call_deferred()` or `call_deferred_thread_group()` instead.
					#   <C++ Error>   Condition "!is_accessible_from_caller_thread()" is true. Returning: (Variant())
					#   <C++ Source>  scene/main/node.cpp:4159 @ get_script()
				# If true, it may randomly crash possibly due to engine bugs with autoloads:
					# https://github.com/godotengine/godot/issues/98865
				use_sub_threads = false
			
			var request_result: int = ResourceLoader.load_threaded_request(resource_uid_request, "Resource", use_sub_threads)
			if request_result != OK:
				push_error("Failed to request resource.")
				return
			
			var progress_ratio_array: Array[float] = []
			while ResourceLoader.load_threaded_get_status(resource_uid_request, progress_ratio_array) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:				
				if progress_ratio_array.size() != 1:
					push_error("Progress ratio array empty?")
					return
				var progress_ratio: float = progress_ratio_array[0]
				var total_progress_ratio: float = ((finished_requests as float) + progress_ratio) / (resource_uid_requests.size() as float)
				_loading_progress_bar.value = total_progress_ratio
				await get_tree().process_frame
			
			if ResourceLoader.load_threaded_get_status(resource_uid_request) != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				push_error("Failed to load resource.")
				return
			var requested_resource: Resource = ResourceLoader.load_threaded_get(resource_uid_request)
			if requested_resource == null:
				push_error("Failed to get resource.")
				return
			
			if resource_uid_request == scene_uid:
				var requested_packed_scene: PackedScene = requested_resource as PackedScene
				if requested_packed_scene == null:
					push_error("Error: scene resource is not a PackedScene")
					return
				scene_packed_scene = requested_packed_scene
				if scene == SceneSwitcher.GameScene.MAIN_SCENE:
					if TIMING_PRINTS: print("SceneSwitcher: cached main scene")
					_cached_main_packed_scene = scene_packed_scene
			elif resource_uid_request in _main_sub_resource_uids:
				if TIMING_PRINTS: print("SceneSwitcher: cached sub resource")
				_cached_sub_resources[resource_uid_request] = requested_resource
			
			var request_end_time_ms: int = Time.get_ticks_msec()
			var request_total_duration_ms: int = request_end_time_ms - request_start_time_ms
			if TIMING_PRINTS: print("SceneSwitcher: resource %s (%s) loading duration: %s ms" % [finished_requests, requested_resource.resource_path, request_total_duration_ms])
			
			finished_requests += 1

		if TIMING_PRINTS: print("SceneSwitcher: done loading, instantiating scene")

	var loading_end_time_ms: int = Time.get_ticks_msec()
	var loading_total_duration_ms: int = loading_end_time_ms - loading_start_time_ms
	if TIMING_PRINTS: print("SceneSwitcher: total loading duration: %s ms" % loading_total_duration_ms)
	
	_loading_progress_bar.visible = false

	var instantiating_start_time_ms: int = Time.get_ticks_msec()
	if TIMING_PRINTS: print("SceneSwitcher: started timing instantiation")

	current_scene = scene_packed_scene.instantiate()
	
	var instantiating_end_time_ms: int = Time.get_ticks_msec()
	var instantiating_total_duration_ms: int = instantiating_end_time_ms - instantiating_start_time_ms
	if TIMING_PRINTS: print("SceneSwitcher: total instantiating duration: %s ms" % instantiating_total_duration_ms)
	
	var add_child_start_time_ms: int = Time.get_ticks_msec()
	if TIMING_PRINTS: print("SceneSwitcher: started timing add_child, current child node count: %s" % _count_children_recursively(self))
	
	add_child(current_scene)

	var add_child_end_time_ms: int = Time.get_ticks_msec()
	var add_child_total_duration_ms: int = add_child_end_time_ms - add_child_start_time_ms
	if TIMING_PRINTS: print("SceneSwitcher: total add_child duration: %s ms, new child count: %s" % [add_child_total_duration_ms, _count_children_recursively(self)])
	
	get_tree().paused = false
	
	loading_tween = create_tween()
	loading_tween.tween_property(loading_screen, "modulate:a", 0, LOADING_FADE_OUT_TIME).from(1)
	await loading_tween.finished
	Events.scene_switch_in_animation_finished.emit()

func quit_game() -> void:
	if current_scene:
		get_tree().paused = true
		loading_tween = create_tween()
		loading_tween.tween_property(loading_screen, "modulate:a", 1, LOADING_FADE_IN_TIME).from(0)
		await loading_tween.finished
		get_tree().quit()


func _scene_enum_to_uid(scene: SceneSwitcher.GameScene) -> StringName:
	match scene:
		SceneSwitcher.GameScene.MAIN_SCENE:
			return _main_scene_uid
		SceneSwitcher.GameScene.MAIN_MENU:
			return _main_menu_uid
		SceneSwitcher.GameScene.END_OF_DAY_DIALOG_SCENE:
			return _end_of_day_dialog_scene_uid
		_:
			push_error("Unhandled Scene!")
			return &""

func _count_children_recursively(node: Node) -> int:
	var child_count: int = 0
	child_count += get_child_count()
	for child_node in node.get_children():
		child_count += _count_children_recursively(child_node)
	return child_count
	
