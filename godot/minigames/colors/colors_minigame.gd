@tool
class_name ColorsMinigame
extends Control

const DELAY_AFTER_PRESSING_BUTTON := 0.75

@export var buttons: Array[ColorsMinigameButton]
@export var needed_successes: int = 3
@export var prompt_text_box: RichTextLabel
@export var correct_sound: AudioStreamPlayer
@export var wrong_sound: AudioStreamPlayer
@export var prompt_print_sound: AudioStreamPlayer
@export var sato_animated_sprite: AnimatedSprite2D

@export_tool_button("Random Prompt") var action: Callable = show_new_prompt

var successes: int = 0
var colors: Array[Color] = [Color(1.0, 0.331, 0.265, 1.0), Color(0.245, 0.467, 1.0, 1.0), Color(0.574, 1.0, 0.543, 1.0)]
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
	for container: ColorsMinigameButton in buttons:
		container.button.pressed.connect(
			func():
				_on_button_pressed(buttons.find(container)),
		)

	show_new_prompt()


func show_new_prompt():
	sato_animated_sprite.play("default")
	current_prompt = prompts_and_corresponding_buttons.keys().pick_random()
	var color:String = str("#",(colors.pick_random() as Color).to_html())
	prompt_text_box.text = "[wave amp=75.0 freq=5.0][center][color=white][outline_size=8][font_size=32][p align=center]Tippy says:[/p][font_size=48][p align=center]Click the[/p][p align=center][color=%s]%s" % [color,current_prompt]
	create_tween().tween_property(prompt_text_box, "visible_ratio", 1, 0.5).from(0)
	prompt_print_sound.play()


func _on_button_pressed(button_index: int):
	if prompts_and_corresponding_buttons[current_prompt] == button_index + 1:
		correct_sound.play()
		sato_animated_sprite.play("correct")
		correct_sound.pitch_scale += 0.1
		prompt_text_box.text = "[wave amp=75.0 freq=15.0][font_size=48][font top_spacing=-0][center]✅"
		successes += 1
	else:
		prompt_text_box.text = "[shake rate=100.0 level=32][font_size=48][font top_spacing=-0][center]❌"
		wrong_sound.play()
		sato_animated_sprite.play("incorrect")

	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	await get_tree().create_timer(DELAY_AFTER_PRESSING_BUTTON, false).timeout
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	if successes >= needed_successes:
		Events.minigame_end.emit()
	else:
		show_new_prompt()
