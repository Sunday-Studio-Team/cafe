extends CanvasLayer
@onready var sub_viewport = $Control/SubViewportContainer/SubViewport

#Minigame List 
@export var minigame_dict : Dictionary[String, PackedScene]



#Adds the minigame to the subviewport so that it is playable
func set_minigame(minigame_name : String):
	var choosen_game : PackedScene = minigame_dict.get(minigame_name)
	#If Null
	if not choosen_game:
		print("This game does not exist")
		#Put a generic "test game" as the default if it doesn't work
	
	#Adds game to the subviewport
	sub_viewport.add_child(choosen_game.instantiate())

#Turns on the minigame and turns on any related functions within the minigame. 
func play_minigame(minigame_name : String):
	#Sets the game
	set_minigame(minigame_name)
	
	visible = true

#Closes the game
func close_game():
	sub_viewport.get_child(0).queue_free()
	visible = false
