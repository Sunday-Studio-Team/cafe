extends Node2D

@export var background_panel: Panel
@export var arrow_output: RichTextLabel
@export var prompt_output: RichTextLabel

var max_arrow_count: int = 10
var blue: String = "#14529F"
var red: String = "#A20B10"
var directions = ["🡄","🡅","🡆","🡇"]
var blue_directions = []
var red_directions = []
var output_directions = []
var valid_indices: Array[int] = []

@onready var background_color = "#" + background_panel.get_theme_stylebox("panel").get("bg_color").to_html(false)

func _ready() -> void:
	arrow_output.text = ""
	var choose_color: float = randi_range(0, 1);
	var color_choice: String
	var text_color: String
	# Choose if player has to click red or blue directions
	if choose_color == 0:
		text_color = blue
		color_choice = "[bgcolor=%s][color=%s]blue[/color][/bgcolor]" % [background_color, text_color]
	else:
		text_color = red
		color_choice = "[bgcolor=%s][color=%s]red[/color][/bgcolor]" % [background_color, text_color]
	
	prompt_output.text = "Press the %s directions!" % color_choice
	
	# Randomly choose arrow directions
	for i in range(max_arrow_count/2):
		blue_directions.append([ directions.pick_random(), blue ])
		red_directions.append([ directions.pick_random(), red ])
	
	# Insert arrows randomly into arrow_output, but chosen sequentially from each direction array
	var bi: int = max_arrow_count/2 - 1
	var ri: int = max_arrow_count/2 - 1
	var blue_valid: bool
	while bi >= 0 and ri >= 0:
		var choose_dir = randi_range(0, 1);
		if choose_dir == 0:
			blue_valid = true
			add_arrow(blue_directions, bi, true)
			bi -= 1
		else:
			blue_valid = false
			add_arrow(red_directions, ri, false)
			ri -= 1
	while bi >= 0:
		add_arrow(blue_directions, bi, true)
		bi -= 1
	while ri >= 0:
		add_arrow(red_directions, ri, false)
		ri -= 1
	
	update_output()
	print(valid_indices)

# color_array can't be statically typed since Nested Type Collections are not supported. Code can be changed to use an array of classes instead.
# build output_directions array, to use to update the output text later
func add_arrow(color_array, index: int, is_valid: bool) -> void:
	if is_valid:
		valid_indices.append(output_directions.size())
	output_directions.append(color_array[index])


func update_output() -> void:
	var output_text: String = ""
	for i in range(output_directions.size()):
		var color: String = output_directions[i][1]
		var arrow: String = output_directions[i][0]
		output_text += "[color=%s]%s[/color]" % [color, arrow]
	arrow_output.text = output_text
