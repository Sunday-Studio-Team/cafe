extends CanvasLayer

@export var play_button: Button
@export var quit_button: Button


func _ready() -> void:
	Global.in_main_menu = true

	play_button.pressed.connect(
		func():
			Global.day = 1
			Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
			Global.in_main_menu = false
	)
	quit_button.pressed.connect(
		func():
			Events.quit_game_requested.emit()
	)
