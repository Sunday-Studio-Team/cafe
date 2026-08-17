extends CanvasLayer
class_name TutorialSelectionMenu

@export var skip_button: Button
@export var continue_button: Button

func _ready() -> void:
	skip_button.pressed.connect(_on_skip)
	continue_button.pressed.connect(_on_continue)


func _on_skip() -> void:
	get_tree().paused = true
	Global.in_tutorial_selection = false
	Global.day = 1
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)


func _on_continue() -> void:
	get_tree().paused = false
	Global.in_tutorial_selection = false
	visible = false


func open_menu() -> void:
	get_tree().paused = true
	Global.in_tutorial_selection = true
	visible = true
