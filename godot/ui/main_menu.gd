extends CanvasLayer

@export var play_button: Button
@export var tutorial_button: Button
@export var quit_button: Button
@export var _options_button: Button
@export var _options_menu_packed_scene: PackedScene


func _ready() -> void:
	Global.in_main_menu = true

	play_button.pressed.connect(
		func():
			if OS.has_feature("tutorial"):
				Global.day = 0
			elif SaveDataManager.save_data.finished_or_skipped_tutorial:
				Global.day = 1
			else:
				Global.day = 0

			load_main_scene(),
	)

	tutorial_button.visible = SaveDataManager.save_data.finished_or_skipped_tutorial
	tutorial_button.pressed.connect(
		func():
			Global.day = 0
			load_main_scene(),
	)

	_options_button.pressed.connect(_on_options_button_pressed)

	quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit(),
	)


func load_main_scene() -> void:
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
	Global.in_main_menu = false


func _on_options_button_pressed() -> void:
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)
