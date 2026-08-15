extends Node2D

@export var background_panel: Panel
@export var arrow_output: RichTextLabel
@export var prompt_output: RichTextLabel
@export var wrong_sign: Control
@export var arrows_container: HBoxContainer
@export var textime: Texture2D

@export_dir var blue_left
@export_dir var blue_up
@export_dir var blue_right
@export_dir var blue_down
@export_dir var red_arrow

var max_arrow_count: int = 10
var blue: String = "#14529F"
var red: String = "#A20B10"
var general_directions = ["left", "up", "right", "down"]
var blue_directions = []
var red_directions = []
var output_directions = []
var valid_indices: Array[int] = []
var input_to_direction: Dictionary = {
	"move_left": "🡄",
	"move_forward": "🡅",
	"move_right": "🡆",
	"move_back": "🡇",
}
var general_direction_to_arrow: Dictionary = {
	"left": ["", "", "", "", "", ""],
	"up": ["", "", "", "", "", ""],
	"right": ["", "", "", "", "", ""],
	"down": ["", "", "", "", "", ""],
}
var correct_input_index: int = 0

@onready var background_color = "#" + background_panel.get_theme_stylebox("panel").get("bg_color").to_html(false)


func _ready() -> void:
	set_up_arrow_container()
	_start_minigame()


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action("move_left"):
			check_input("left")
		if event.is_action("move_forward"):
			check_input("up")
		if event.is_action("move_right"):
			check_input("right")
		if event.is_action("move_back"):
			check_input("down")

	if correct_input_index >= valid_indices.size():
		_end_minigame()


func check_input(direction: String) -> void:
	var valid_index: int = valid_indices[correct_input_index]

	if general_direction_to_arrow[direction].has(output_directions[valid_index][0]):
		output_directions[valid_index][1] = background_color
		correct_input_index += 1
		update_output()
	else:
		display_wrong()
		_start_minigame()


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
		output_text += "[color=%s]%s [/color]" % [color, arrow]
	arrow_output.text = output_text


func display_wrong() -> void:
	wrong_sign.visible = true
	await get_tree().create_timer(.4).timeout
	wrong_sign.visible = false


func set_up_arrow_container() -> void:
	var container_horizontal_size: float = arrows_container.size.x
	var required_separation_spaces: float = arrows_container.get_theme_constant("separation") * max_arrow_count
	var min_arrow_size: float = (container_horizontal_size - required_separation_spaces) / (max_arrow_count)
	for arrow in max_arrow_count:
		var arrow_rect = TextureRect.new()
		arrow_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		arrow_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		arrow_rect.custom_minimum_size.x = min_arrow_size
		arrow_rect.texture = textime
		arrows_container.add_child(arrow_rect)


func _start_minigame() -> void:
	arrow_output.text = ""

	blue_directions = []
	red_directions = []
	output_directions = []
	valid_indices = []
	correct_input_index = 0

	var choose_color: float = randi_range(0, 1)
	var blue_valid: bool
	var color_choice: String
	var text_color: String
	# Choose if player has to click red or blue directions
	var text_colors = [blue, red]
	if choose_color == 0:
		blue_valid = true
		text_color = text_colors.pick_random()
		color_choice = "[bgcolor=%s][color=%s]blue[/color][/bgcolor]" % [background_color, text_color]
	else:
		blue_valid = false
		text_color = text_colors.pick_random()
		color_choice = "[bgcolor=%s][color=%s]red[/color][/bgcolor]" % [background_color, text_color]

	prompt_output.text = "Press the %s directions!" % color_choice

	# Randomly choose arrow directions
	for i in range(max_arrow_count / 2):
		blue_directions.append([general_direction_to_arrow[general_directions.pick_random()].pick_random(), blue])
		red_directions.append([general_direction_to_arrow[general_directions.pick_random()].pick_random(), red])

	# Insert arrows randomly into arrow_output, but chosen sequentially from each direction array
	var bi: int = max_arrow_count / 2 - 1
	var ri: int = max_arrow_count / 2 - 1
	while bi >= 0 and ri >= 0:
		var choose_dir = randi_range(0, 1)
		if choose_dir == 0:
			add_arrow(blue_directions, bi, blue_valid)
			bi -= 1
		else:
			add_arrow(red_directions, ri, !blue_valid)
			ri -= 1
	while bi >= 0:
		add_arrow(blue_directions, bi, blue_valid)
		bi -= 1
	while ri >= 0:
		add_arrow(red_directions, ri, !blue_valid)
		ri -= 1

	update_output()


func _end_minigame() -> void:
	Events.minigame_end.emit()
