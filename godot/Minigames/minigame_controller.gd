extends CanvasLayer

@export var minigame_dict: Dictionary[String, PackedScene]
@export var sub_viewport: SubViewport


func play_minigame(minigame_name: String):
	var choosen_game: PackedScene = minigame_dict.get(minigame_name)

	# If Null
	if not choosen_game:
		print("This game does not exist")

	sub_viewport.add_child(choosen_game.instantiate())

	visible = true


func close_game():
	sub_viewport.get_child(0).queue_free()
	visible = false
