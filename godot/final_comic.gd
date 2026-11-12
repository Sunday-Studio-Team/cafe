extends Node2D

@export var comic_panel_array: Array[Texture2D] = []
@export var comic_panel_2d_sprite_renderer: Sprite2D
@export var next_panel_button: TextureButton

var current_panel_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.in_ending_comic = true
	next_panel_button.pressed.connect(
		func():
		if current_panel_index >= comic_panel_array.size() - 1:
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU, true)
		else:
			_on_button_pressed()
	)

	next_panel_button.mouse_entered.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(next_panel_button, "offset_transform_scale", Vector2.ONE * 1.1, 0.1)
			t.tween_property(next_panel_button, "offset_transform_rotation", deg_to_rad(-1), 0.1),
	)
	next_panel_button.mouse_exited.connect(
		func():
			var t := create_tween().set_parallel()
			t.tween_property(next_panel_button, "offset_transform_scale", Vector2.ONE, 0.1)
			t.tween_property(next_panel_button, "offset_transform_rotation", deg_to_rad(1), 0.1),
	)
	_update_comic_panel_image()


func _exit_tree() -> void:
	Global.in_ending_comic = false


func _on_button_pressed() -> void:
	current_panel_index = current_panel_index + 1
	_update_comic_panel_image()


func _update_comic_panel_image() -> void:
	var loaded_comic_panel: Texture2D = comic_panel_array[current_panel_index]
	comic_panel_2d_sprite_renderer.texture = loaded_comic_panel
