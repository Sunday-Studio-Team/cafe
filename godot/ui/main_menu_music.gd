extends AudioStreamPlayer


func _ready() -> void:
	Events.scene_switch_requested.connect(
		# i dont know why this needs 2 parameters when the signal only has 1
		func(scene: SceneSwitcher.GameScene, _skip_intro: bool = false) -> void:
			if (
				scene == SceneSwitcher.GameScene.MAIN_MENU
				or scene == SceneSwitcher.GameScene.LEVEL_SELECT
			):
				if not playing:
					play()
			elif scene == SceneSwitcher.GameScene.MAIN_SCENE:
				stop()
)
