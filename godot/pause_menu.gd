extends CanvasLayer

@export var quit_button: Button


func _ready() -> void:
	quit_button.pressed.connect(func(): get_tree().quit())


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not Global.minigame_active:
		get_tree().paused = !get_tree().paused
		visible = !visible

		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
