class_name SceneSwitcher
extends Node

enum GameScene {
	MAIN_SCENE,
	MAIN_MENU,
	END_OF_DAY_DIALOG_SCENE,
}

const LOADING_FADE_IN_TIME := 0.5
const LOADING_FADE_OUT_TIME := 1.0

static var _instance: SceneSwitcher

@export var loading_screen: ColorRect
@export var _loading_progress_bar: ProgressBar
@export var loading_icons: Control
@export var _main_scene_uid: StringName
@export var _main_menu_uid: StringName
@export var _end_of_day_dialog_scene_uid: StringName

var current_scene: Node = null
var loading_tween: Tween


func _ready() -> void:
	Events.scene_switch_requested.connect(load_scene)
	Events.quit_game_requested.connect(quit_game)
	
	if OS.has_feature("editor"):
		load_scene(SceneSwitcher.GameScene.MAIN_SCENE)
	else:
		load_scene(SceneSwitcher.GameScene.MAIN_MENU)


func _physics_process(_delta: float) -> void:
	loading_icons.visible = loading_screen.modulate.a == 1


func load_scene(scene: SceneSwitcher.GameScene) -> void:
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

	var scene_uid: StringName = _scene_enum_to_uid(scene)
	var request_result: int = ResourceLoader.load_threaded_request(scene_uid)
	if request_result != OK:
		push_error("Failed to request scene.")
		return
	var progress_ratio_array: Array[float] = []
	while ResourceLoader.load_threaded_get_status(scene_uid, progress_ratio_array) == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		if progress_ratio_array.size() > 0:
			var progress_ratio: float = progress_ratio_array[0]
			_loading_progress_bar.value = progress_ratio
		await get_tree().process_frame
	if ResourceLoader.load_threaded_get_status(scene_uid) != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		push_error("Failed to load scene.")
		return
	var scene_resource: Resource = ResourceLoader.load_threaded_get(scene_uid)
	if scene_resource == null:
		push_error("Failed to get scene resource.")
		return
	var scene_packed_scene: PackedScene = scene_resource as PackedScene
	if scene_packed_scene == null:
		push_error("Error: scene resource is not a PackedScene")
		return

	_loading_progress_bar.visible = false

	current_scene = scene_packed_scene.instantiate()
	add_child(current_scene)
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
