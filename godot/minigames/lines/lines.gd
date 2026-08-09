extends Control

@export var background_panel: Control
@export var wire_1: Button
@export var wire_2: Button
@export var wire_3: Button
@export var wire_holder: CanvasLayer
@export var label: Label

@export var needed_successes: int = 3

var accepting_input := true
var current_choice: String
var successes: int = 0
var colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
]

var choices = {
	"Red Wire" : 1,
	"Top Wire" : 1,
	"Blue Wire" : 2,
	"Middle Wire" : 2,
	"Green Wire" : 3,
	"Bottom Wire": 3,
}

var last_click_correct := false

func _ready():
	set_choice()
	
#Sets the text randomly
func set_choice():
	if last_click_correct:
		accepting_input = false
		await get_tree().create_timer(0.5, false).timeout
		accepting_input = true
	last_click_correct = false
	current_choice = choices.keys().pick_random()
	label.text = "Click the %s" % current_choice
	label.add_theme_color_override("font_color", colors.pick_random())
	
	
func _on_button_pressed():
	if not accepting_input:
		return

	print(successes)
	if choices[current_choice] == 1:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
		else:
			for item in choices.keys():
				if choices[item] == 1:
					choices.erase(item)
			wire_1.hide()


func _on_button_2_pressed():
	if not accepting_input:
		return

	if choices[current_choice] == 2:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
		else:
			for item in choices.keys():
				if choices[item] == 2:
					choices.erase(item)
			wire_2.hide()
		

func _on_button_3_pressed():
	if not accepting_input:
		return

	if choices[current_choice] == 3:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
		else:
			for item in choices.keys():
				if choices[item] == 3:
					choices.erase(item)
			wire_3.hide()
	
#Sends out needed information if the vicotry is achived.
func victory():
	await get_tree().create_timer(0.5, false).timeout
	Events.emit_signal("minigame_end")
