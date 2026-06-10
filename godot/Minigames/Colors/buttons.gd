extends Control

@export var needed_successes: int = 3

var current_choice: Array
var successes: int = 0
var colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
]
var choices = [
	["Red Square", 1],
	["Blue A", 1],
	["Blue Square", 2],
	["Green B", 2],
	["Green Square", 3],
	["Red C", 3],
]
var last_click_correct := false

@onready var text_edit = $PanelContainer/Panel/TextEdit
@onready var timer = $Timer


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_choice()


#Sets the text randomly
func set_choice():
	if last_click_correct:
		text_edit.text = "✅"
		await get_tree().create_timer(0.5, false).timeout
	last_click_correct = false
	current_choice = choices.pick_random()
	text_edit.text = current_choice[0]
	text_edit.add_theme_color_override("font_color", colors.pick_random())


#Does the error if the wrong button is pressed
func wrong_button_pressed():
	text_edit.text = "ERROR"
	text_edit.add_theme_color_override("font_color", Color.DARK_RED)
	timer.start(1)


#Sends out needed information if the vicotry is achived.
func victory():
	text_edit.text = "✅"
	await get_tree().create_timer(0.5, false).timeout
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Events.emit_signal("minigame_end")


func _on_button_pressed():
	print(successes)
	if current_choice[1] == 1:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
	else:
		wrong_button_pressed()


func _on_button_2_pressed():
	if current_choice[1] == 2:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
	else:
		wrong_button_pressed()


func _on_button_3_pressed():
	if current_choice[1] == 3:
		successes += 1
		last_click_correct = true
		set_choice()
		if successes >= needed_successes:
			victory()
	else:
		wrong_button_pressed()


func _on_timer_timeout():
	set_choice()
