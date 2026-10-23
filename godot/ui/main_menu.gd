extends CanvasLayer

@export var play_button: TextureButton
@export var quit_button: TextureButton
@export var _options_button: TextureButton
@export var _options_menu_packed_scene: PackedScene
@export var discord_button: TextureButton
@export var instagram_button: TextureButton

const DISCORD_URL := "https://discord.com/invite/WqhGAnZWCq"
const INSTAGRAM_URL := "https://www.instagram.com/sundaystudiosgames/"


func _ready() -> void:
	Global.in_main_menu = true

	play_button.pressed.connect(
		func():
			Global.in_main_menu = false
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.LEVEL_SELECT)
	)

	_options_button.pressed.connect(_on_options_button_pressed)

	quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit(),
	)
	
	discord_button.pressed.connect(_open_discord)
	instagram_button.pressed.connect(_open_instagram)

func _on_options_button_pressed() -> void:
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)

func _open_discord() -> void:
	OS.shell_open(DISCORD_URL)
	
func _open_instagram() -> void:
	OS.shell_open(INSTAGRAM_URL)
