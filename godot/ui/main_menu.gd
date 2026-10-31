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
@export var _hover_sound: AudioStreamPlayer
@export var _click_sound: AudioStreamPlayer
@export var UI: Node2D
@export var game_logo: Sprite2D
@export var sato_anim: Node2D


@export_dir var _save_file_path: String


func _ready() -> void:
	UI.hide()
	
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

	setup_button_sounds()

	game_logo.scale = Vector2.ZERO
	game_logo.modulate.a = 1.0
	game_logo.visible = true
	
	sato_anim.scale = Vector2.ZERO
	sato_anim.modulate.a = 1.0
	sato_anim.visible = true
	
	UI.modulate.a = 0.0
	await get_tree().create_timer(0.8).timeout
	_background_sprite.play("menu_start")
	await _background_sprite.animation_finished
	await get_tree().create_timer(0.05).timeout
	var tween: Tween = create_tween()
	tween.tween_property(UI, "modulate:a", 1.0, 1.0)

	# reveal all UI here
	UI.show()
		
	slide_ui_buttons()

	tween.tween_property(game_logo, "scale", Vector2.ONE, 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sato_anim, "scale", Vector2.ONE, 0.6)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
			

	for child in _buttons_parent_node.get_children():
		if child is TextureButton and child.texture_normal:
			var image: Image = child.texture_normal.get_image()
			var bitmap: BitMap = BitMap.new()
			# assign alpha channel as mask so that overlapping
			# rects from other rightly placed buttons do not block
			# button presses
			bitmap.create_from_image_alpha(image)
			child.texture_click_mask = bitmap


func _on_options_button_pressed() -> void:
	Global.options_menu_show_delete_save_file = true
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)


func _open_discord() -> void:
	OS.shell_open(DISCORD_URL)


func _open_instagram() -> void:
	OS.shell_open(INSTAGRAM_URL)


func setup_button_sounds() -> void:
	for b: BaseButton in find_children("*", "BaseButton"):
		b.mouse_entered.connect(
				func() -> void:
					_hover_sound.pitch_scale = randf_range(0.9, 1.1)
					_hover_sound.play()
		)

		b.pressed.connect(
				func() -> void:
					_click_sound.pitch_scale = randf_range(0.9, 1.1)
					_click_sound.play()
		)

func slide_ui_buttons() -> void:
	var children = _buttons_parent_node.get_children()
	
	for i in range(children.size()):
		var child = children[i] as Control
		if not child:
			continue
			
		child.visible = true
		child.modulate.a = 1.0
		
		# push all the way back
		var target_x = child.position.x
		var target_y = child.position.y

		if (2 - i) > 0:
			print('first')
			child.position.x = target_x - 800
			child.position.y = target_y
		elif (2 - i) < 0:
			print('second')
			child.position.x = target_x
			child.position.y = target_y + 800
		else:
			print('third')
			child.position.x = target_x - 800
			child.position.y = target_y + 800

		var tween = create_tween()
		tween.tween_interval(i * 0.15) 

		var sub_tween = create_tween().set_parallel(true)
		sub_tween.tween_property(child, "position:x", target_x, 0.5)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
		sub_tween.tween_property(child, "position:y", target_y, 0.5)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
