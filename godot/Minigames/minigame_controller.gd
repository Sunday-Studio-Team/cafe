extends CanvasLayer

@export var minigame_dict: Dictionary[String, PackedScene]
@export var sub_viewport: SubViewport


func _ready() -> void:
	Events.time_up.connect(
		func():
			if Global.minigame_active:
				close_game()
	)
	
	Events.force_close_minigame.connect(_on_force_close_minigame)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and Global.minigame_active:
		close_game()
		Events.minigame_cancelled.emit()


func play_minigame(minigame_name: String):
	var choosen_game: PackedScene = minigame_dict.get(minigame_name)

	# If Null
	if not choosen_game:
		print("This game does not exist")

	sub_viewport.add_child(choosen_game.instantiate())

	visible = true
	Global.minigame_active = true


func close_game():
	sub_viewport.get_child(0).queue_free()
	visible = false
	Global.minigame_active = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_force_close_minigame() -> void:
	if Global.minigame_active:
		close_game()
