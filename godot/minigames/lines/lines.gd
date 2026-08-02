extends Control

#Sends out needed information if the vicotry is achived.
func victory():
	await get_tree().create_timer(0.5, false).timeout
	Events.emit_signal("minigame_end")
