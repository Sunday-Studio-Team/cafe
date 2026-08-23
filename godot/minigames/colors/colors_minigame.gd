@tool
extends Control

const DELAY_AFTER_PRESSING_BUTTON := 0.75

@export var buttons: Array[MachineFixButton]
@export var needed_successes: int = 3
@export var prompt_panel: Control
@export var prompt_text_box: RichTextLabel
@export var employee_texture_rect:TextureRect
@export var correct_sound: AudioStreamPlayer
@export var wrong_sound: AudioStreamPlayer

@export_tool_button("Random Prompt") var action = show_new_prompt

const employee_default:Texture2D = preload("res://sprites/machine_fix_buttons_minigame/tippy_buttons_normal.png")
const employee_happy:Texture2D = preload("res://sprites/machine_fix_buttons_minigame/tippy_buttons_happy_1.png")
const employee_anxiety:Texture2D = preload("res://sprites/machine_fix_buttons_minigame/tippy_buttons_anx_1.png")

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
	for container: MachineFixButton in buttons:
		container.button.pressed.connect(
			func():
				_on_button_pressed(buttons.find(container)),
		)
	show_new_prompt()

func set_employee_face(texture:Texture2D=employee_default):
	employee_texture_rect.texture = texture

func show_new_prompt():
	set_employee_face()
	current_prompt = prompts_and_corresponding_buttons.keys().pick_random()
	var color:String = str("#",(colors.pick_random() as Color).to_html())
	#prompt_text_box.add_theme_color_override("font_color", colors.pick_random())
	prompt_text_box.text = "[wave amp=75.0 freq=5.0][center][color=white][outline_size=8][font_size=24][p align=center]Tippy says:[/p][font_size=32][p align=center]Click the[/p][font top_spacing=-16][p align=center][color=%s]%s" % [color,current_prompt]

func _on_button_pressed(button_index: int):
	if prompts_and_corresponding_buttons[current_prompt] == button_index + 1:
		correct_sound.play()
		correct_sound.pitch_scale += 0.1
		prompt_text_box.text = "[wave amp=75.0 freq=15.0][font_size=48][font top_spacing=-0][center]✅"
		set_employee_face(employee_happy)
		successes += 1
	else:
		set_employee_face(employee_anxiety)
		prompt_text_box.text = "[shake rate=100.0 level=32][font_size=48][font top_spacing=-0][center]❌"
		wrong_sound.play()
		#var shake_tween := create_tween().set_trans(Tween.TRANS_SPRING)
		#shake_tween.tween_property(prompt_panel, "offset_transform_position_ratio:x", 0.1, 0.1)
		#shake_tween.tween_property(prompt_panel, "offset_transform_position_ratio:x", -0.1, 0.1)
		#shake_tween.tween_property(prompt_panel, "offset_transform_position_ratio:x", 0, 0.1)

	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	await get_tree().create_timer(DELAY_AFTER_PRESSING_BUTTON, false).timeout
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	if successes >= needed_successes:
		Events.emit_signal("minigame_end")
	else:
		show_new_prompt()
