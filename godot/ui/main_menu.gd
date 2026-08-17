extends CanvasLayer

@export var play_button: Button
@export var _options_button: Button
@export var _options_menu_packed_scene: PackedScene
@export var quit_button: Button


func _ready() -> void:
	Global.in_main_menu = true

	play_button.pressed.connect(
		func():
			Global.day = 0
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
			Global.in_main_menu = false
	)
	_options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit()
	)

func _on_options_button_pressed() -> void:
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)
