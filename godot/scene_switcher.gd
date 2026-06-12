extends Node

const LOADING_FADE_IN_TIME := 1.0
const LOADING_FADE_OUT_TIME := 2.0

@export var loading_screen: ColorRect
@export var main_scene: PackedScene

var current_scene: Node = null
var loading_tween: Tween


func _ready() -> void:
	load_scene(main_scene)
	Events.main_scene_loaded.connect(func(): load_scene(main_scene))


func load_scene(scene: PackedScene) -> void:
	if current_scene:
		get_tree().paused = true
		loading_tween = create_tween()
		loading_tween.tween_property(loading_screen, "modulate:a", 1, LOADING_FADE_IN_TIME).from(0)
		await loading_tween.finished
		current_scene.queue_free()
		await current_scene.tree_exited
	current_scene = scene.instantiate()
	add_child(current_scene)
	get_tree().paused = false
	loading_tween = create_tween()
	loading_tween.tween_property(loading_screen, "modulate:a", 0, LOADING_FADE_OUT_TIME).from(1)
