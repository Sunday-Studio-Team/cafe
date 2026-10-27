extends AudioStreamPlayer


func _ready() -> void:
	# this autoplays unless we're running in editor (cos thatll miss some signals)
	if OS.has_feature("editor") and not OS.has_feature("editor_start_main_menu"):
		stop()

	Events.scene_switch_requested.connect(
		func(scene: SceneSwitcher.GameScene) -> void:
			if (
				scene == SceneSwitcher.GameScene.MAIN_MENU
				or scene == SceneSwitcher.GameScene.LEVEL_SELECT
			):
				if not playing:
					play()
			elif scene == SceneSwitcher.GameScene.MAIN_SCENE:
				stop()
)
