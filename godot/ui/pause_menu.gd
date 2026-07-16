extends CanvasLayer

@export var quit_button: Button
@export var restart_button: Button

var in_end_screen := false


func _ready() -> void:
	quit_button.pressed.connect(func(): Events.main_menu_loaded.emit())
	restart_button.pressed.connect(
		func():
			visible = false
			get_tree().paused = false
			Global.day = 1
			Events.main_scene_loaded.emit()
	)
	Events.time_up.connect(
		func():
			in_end_screen = true
	)


func _physics_process(_delta: float) -> void:
	if (
			Input.is_action_just_pressed("pause")
			and not Global.in_ui
	):
		get_tree().paused = !get_tree().paused
		visible = !visible
