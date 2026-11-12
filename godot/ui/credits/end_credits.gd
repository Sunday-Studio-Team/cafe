extends CanvasLayer

@export var force_mouse_mode_visible : bool = false

func exit_game() -> void:
	get_tree().quit()


# TODO
# add optional logic for when the credits finish
# for example, couuld display end screen message with buttons
func _end_reached() -> void:
	exit_game()


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_released("pause"):
		exit_game()


func _on_exit_button_pressed():
	exit_game()
