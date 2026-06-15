extends CanvasLayer

@export var play_button: Button
@export var quit_button: Button


func _ready() -> void:
	play_button.pressed.connect(
		func():
			Global.day = 1
			Events.main_scene_loaded.emit()
	)
	quit_button.pressed.connect(
		func():
			Events.game_quit.emit()
	)
