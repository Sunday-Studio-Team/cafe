extends SubViewportContainer

@export var background_panel: Panel
@export var arrow_output: RichTextLabel
@export var prompt_output: RichTextLabel
@export var wrong_sign: Control
@export var arrows_container: HBoxContainer

@export var blue_left: Array[Texture]
@export var blue_up: Array[Texture]
@export var blue_right: Array[Texture]
@export var blue_down: Array[Texture]
@export var red_left: Array[Texture]
@export var red_up: Array[Texture]
@export var red_right: Array[Texture]
@export var red_down: Array[Texture]

@export var correct_sound: AudioStreamPlayer
@export var wrong_sound: AudioStreamPlayer

var max_arrow_count: int = 10
var blue: String = "#14529F"
var red: String = "#A20B10"
var general_directions: Array[String] = ["left", "up", "right", "down"]
var general_colors: Array[String] = ["blue", "red"]
var blue_textures = []
var red_textures = []
var output_directions = []
var valid_indices = []
var valid_directions = []
var general_direction_to_arrow: Dictionary = {
	"left": ["", "", "", "", "", ""],
	"up": ["", "", "", "", "", ""],
	"right": ["", "", "", "", "", ""],
	"down": ["", "", "", "", "", ""],
}
var correct_input_index: int = 0

@onready var get_arrow_array: Dictionary = {
	"blue": { "left": blue_left, "up": blue_up, "right": blue_right, "down": blue_down },
	"red": { "left": red_left, "up": red_up, "right": red_right, "down": red_down },
}
@onready var background_color = "#ffffff"


#@onready var background_color = "#" + background_panel.get_theme_stylebox("panel").get("bg_color").to_html(false)
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

	if correct_input_index >= valid_directions.size():
		await correct_sound.finished
		_end_minigame()


func check_input(direction: String) -> void:
	# Tippy dancing should go here
	if (valid_directions[correct_input_index] == direction):
		output_directions[valid_indices[correct_input_index]].texture = null
		correct_input_index += 1
		correct_sound.play()
	else:
		# Angry tippy face here
		display_wrong()
		_start_minigame()


func add_arrow_to_output(
	output_index: int,
	color: String,
	color_index: int,
	correct_color: String,
) -> void:
	if (color == "blue"):
		output_directions[output_index].texture = blue_textures[color_index]
	else:
		output_directions[output_index].texture = red_textures[color_index]

	# While adding to the output array, we keep track of the valid (output) indices here, in order to access the arrows that we make invisible
	if correct_color == color:
		valid_indices.append(output_index)


func display_wrong() -> void:
	wrong_sign.visible = true
	wrong_sound.play()
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
		arrows_container.add_child(arrow_rect)


func _start_minigame() -> void:
	blue_textures = []
	red_textures = []
	output_directions = arrows_container.get_children()
	valid_indices = []
	valid_directions = []
	correct_input_index = 0

	#output_directions[0].texture = blue_left[0]

	# Choose if player has to click red or blue directions
	var choose_color: String = general_colors.pick_random()
	var color_choice: String
	var text_color: String
	# Create the colored text in the game tooltip
	if choose_color == "blue":
		text_color = general_colors.pick_random()
		#color_choice = "[bgcolor=%s][color=%s]blue[/color][/bgcolor]" % [background_color, text_color]
		color_choice = "[color=%s]blue[/color]" % [text_color]
	else:
		text_color = general_colors.pick_random()
		#color_choice = "[bgcolor=%s][color=%s]red[/color][/bgcolor]" % [background_color, text_color]
		color_choice = "[color=%s]red[/color]" % [text_color]
	prompt_output.text = "Press the %s directions!" % color_choice

	# Choose a pool of [max_arrow_count / (general_colors.size())] arrows for each color (likely 2, for blue and red)
	# Since the random arrow directions chosen here are added to the output in order, we keep track of the correct directions here
	# (after the if(choose_color == ...) part
	@warning_ignore("integer_division")
	for i in range(max_arrow_count / (general_colors.size())):
		var blue_dir: String = general_directions.pick_random()
		blue_textures.append(get_arrow_array["blue"][blue_dir].pick_random())
		if (choose_color == "blue"):
			valid_directions.append(blue_dir)

		var red_dir: String = general_directions.pick_random()
		red_textures.append(get_arrow_array["red"][red_dir].pick_random())
		if (choose_color == "red"):
			valid_directions.append(red_dir)

	# Insert arrows randomly into arrow_output, but chosen sequentially from each direction array
	@warning_ignore("integer_division") var individual_color_max: int = max_arrow_count / 2 - 1
	var bi: int = 0
	var ri: int = 0
	var output_index: int = 0
	while bi <= individual_color_max and ri <= individual_color_max:
		var rand_color = general_colors.pick_random()
		if rand_color == "blue":
			add_arrow_to_output(output_index, rand_color, bi, choose_color)
			bi += 1
		else:
			add_arrow_to_output(output_index, rand_color, ri, choose_color)
			ri += 1
		output_index += 1
	while bi <= individual_color_max:
		add_arrow_to_output(output_index, "blue", bi, choose_color)
		bi += 1
		output_index += 1
	while ri <= individual_color_max:
		add_arrow_to_output(output_index, "red", ri, choose_color)
		ri += 1
		output_index += 1


func _end_minigame() -> void:
	Events.minigame_end.emit()
	print("End arrows minigame")
