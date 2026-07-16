extends CanvasLayer

@export var play_button: Button
@export var quit_button: Button


func _ready() -> void:
	Global.in_main_menu = true

	play_button.pressed.connect(
		func():
			Global.day = 1
			Events.main_scene_loaded.emit()
			Global.in_main_menu = false
	)
	quit_button.pressed.connect(
		func():
			Events.game_quit.emit()
	)
