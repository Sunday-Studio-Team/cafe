extends Control

var letter_value: String = ""
var fall_speed: float = 40.0
var dragging: bool = false
var falling: bool = true
var locked: bool = false

@onready var label = $Label

func _ready():
	label.text = letter_value

func _process(delta):
	if falling and not dragging and not locked:
		position.y += fall_speed * delta

func _gui_input(event):
	if locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			falling = false
		else:
			dragging = false
			check_drop()
	elif event is InputEventMouseMotion and dragging:
		position += event.relative

func check_drop():
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	for lane in game_manager.get_lanes():
		if get_global_rect().intersects(lane.get_global_rect()):
			if lane.try_place(self):
				locked = true
				global_position = lane.global_position
				game_manager.on_correct_placement()
			else:
				game_manager.on_wrong_placement()
			return
	falling = true 
