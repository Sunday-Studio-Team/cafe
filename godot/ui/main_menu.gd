extends CanvasLayer

@export var play_button: TextureButton
@export var continue_button: TextureButton
@export var quit_button: TextureButton
@export var _options_button: TextureButton
@export var _options_menu_packed_scene: PackedScene


func _ready() -> void:
	Global.in_main_menu = true
	
	if FileAccess.file_exists("user://save_data.tres"):
		print("Continue")
		%NewGame.visible = false
		%Continue.visible = true
	else:
		print("New Game")
		%NewGame.visible = true
		%Continue.visible = false
	
	play_button.pressed.connect(
		func():
			Global.in_main_menu = false
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
			print("Dapet ke main scene")
	)
	
	continue_button.pressed.connect(
		func():
			Global.in_main_menu = false
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.LEVEL_SELECT)
	)

	_options_button.pressed.connect(_on_options_button_pressed)

	quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit(),
	)

func _on_options_button_pressed() -> void:
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)
