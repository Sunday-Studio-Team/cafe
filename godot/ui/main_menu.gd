class_name MainMenu
extends CanvasLayer

const DISCORD_URL := "https://discord.com/invite/WqhGAnZWCq"
const INSTAGRAM_URL := "https://www.instagram.com/sundaystudiosgames/"

@export var _background_sprite: AnimatedSprite2D
@export var _buttons_parent_node: Control
@export var _new_game_button: TextureButton
@export var _continue_button: TextureButton
@export var _quit_button: TextureButton
@export var _options_button: TextureButton
@export var _options_menu_packed_scene: PackedScene
@export var _discord_button: Button
@export var _instagram_button: Button

@export_dir var _save_file_path: String


func _ready() -> void:
	Global.in_main_menu = true

	if FileAccess.file_exists(_save_file_path):
		_new_game_button.visible = false
		_continue_button.visible = true
	else:
		_new_game_button.visible = true
		_continue_button.visible = false

	_new_game_button.pressed.connect(
		func():
			Global.in_main_menu = false
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
	)

	_continue_button.pressed.connect(
		func():
			Global.in_main_menu = false
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.LEVEL_SELECT)
	)

	_options_button.pressed.connect(_on_options_button_pressed)

	_quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit(),
	)

	_discord_button.pressed.connect(_open_discord)

	_instagram_button.pressed.connect(_open_instagram)

	_buttons_parent_node.modulate.a = 0.0
	_background_sprite.play("menu_start")
	await _background_sprite.animation_finished
	await get_tree().create_timer(0.2).timeout
	var tween = create_tween()
	tween.tween_property(_buttons_parent_node, "modulate:a", 1.0, 1.0)

	for child in _buttons_parent_node.get_children():
		if child is TextureButton and child.texture_normal:
			var image = child.texture_normal.get_image()
			var bitmap = BitMap.new()
			# assign alpha channel as mask so that overalapping
			# rects from other rightly placed buttons do not block
			# button presses
			bitmap.create_from_image_alpha(image)
			child.texture_click_mask = bitmap


func _on_options_button_pressed() -> void:
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)


func _open_discord() -> void:
	OS.shell_open(DISCORD_URL)


func _open_instagram() -> void:
	OS.shell_open(INSTAGRAM_URL)
