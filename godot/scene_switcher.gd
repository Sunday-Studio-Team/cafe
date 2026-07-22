extends Node

const LOADING_FADE_IN_TIME := 0.5
const LOADING_FADE_OUT_TIME := 1.0

@export var loading_screen: ColorRect
@export var loading_icons: Control
@export var main_scene: PackedScene
@export var main_menu: PackedScene

var current_scene: Node = null
var loading_tween: Tween


func _ready() -> void:
	if OS.has_feature("editor"):
		load_scene(main_scene)
	else:
		load_scene(main_menu)
	Events.main_scene_loaded.connect(func(): load_scene(main_scene))
	Events.main_menu_loaded.connect(func(): load_scene(main_menu))
	Events.game_quit.connect(func(): quit())

func _physics_process(_delta: float) -> void:
	# (disabled for now cos they seemed to not actually be showing during the
	# loading hitch after pressing play in build)
	#loading_icons.visible = loading_screen.modulate.a == 1
	loading_icons.hide()

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


func quit() -> void:
	if current_scene:
		get_tree().paused = true
		loading_tween = create_tween()
		loading_tween.tween_property(loading_screen, "modulate:a", 1, LOADING_FADE_IN_TIME).from(0)
		await loading_tween.finished
		get_tree().quit()
