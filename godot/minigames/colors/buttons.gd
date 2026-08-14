extends Control

const DELAY_AFTER_PRESSING_BUTTON := 1.0

@export var buttons: Array[Button]
@export var needed_successes: int = 3
@export var prompt_text_box: TextEdit

var successes: int = 0
var colors = [Color.RED, Color.BLUE, Color.GREEN]
var prompts_and_corresponding_buttons: Dictionary = {
	"Red Square": 1,
	"Blue A": 1,
	"Blue Square": 2,
	"Green B": 2,
	"Green Square": 3,
	"Red C": 3,
}
var current_prompt: String


func _ready():
	for button: Button in buttons:
		button.pressed.connect(
			func():
				_on_button_pressed(buttons.find(button)),
		)

	show_new_prompt()


func show_new_prompt():
	current_prompt = prompts_and_corresponding_buttons.keys().pick_random()
	prompt_text_box.text = current_prompt
	prompt_text_box.add_theme_color_override("font_color", colors.pick_random())


func _on_button_pressed(button_index: int):
	if prompts_and_corresponding_buttons[current_prompt] == button_index + 1:
		prompt_text_box.text = "✅"
		successes += 1
	else:
		prompt_text_box.text = "❌"

	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	await get_tree().create_timer(DELAY_AFTER_PRESSING_BUTTON, false).timeout
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	if successes >= needed_successes:
		Events.emit_signal("minigame_end")
	else:
		show_new_prompt()
