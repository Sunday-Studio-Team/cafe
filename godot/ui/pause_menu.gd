extends CanvasLayer

@export var quit_button: Button
@export var restart_button: Button

var in_end_screen := false


func _ready() -> void:
	quit_button.pressed.connect(func(): get_tree().quit())
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
		and not Global.minigame_active
		and not Global.in_pc_ui
		and not in_end_screen
	):
		get_tree().paused = !get_tree().paused
		visible = !visible

		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
