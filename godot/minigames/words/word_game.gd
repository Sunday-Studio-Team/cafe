extends Control

const LANE = preload("res://minigames/words/lane.tscn")
const LETTER = preload("res://minigames/words/letter.tscn")

var words = ["SORRY", "THANKS", "HELLO"]
var target_word = ""
var lanes = []
var correct_count = 0
var game_over = false

@onready var lane_container = $CanvasLayer/UI/CenterContainer/Lanes
@onready var letters_container = $CanvasLayer/Letters
@onready var timer_bar = $CanvasLayer/Timer
@onready var game_timer = $GameTimer

func _ready():

	add_to_group("game_manager")
	target_word = words.pick_random()
	timer_bar.min_value = 0
	timer_bar.max_value = 8
	setup_lanes()
	setup_letters()
	game_timer.timeout.connect(on_time_up)
	game_timer.start()

func setup_lanes():
	for letter in target_word:
		var lane = LANE.instantiate()
		lane.expected_letter = letter
		lane_container.add_child(lane)
		lanes.append(lane)

func setup_letters():
	for letter in target_word:
		var letter_node = LETTER.instantiate()
		letter_node.letter_value = letter
		letter_node.position = Vector2(randf_range(50, 500), randf_range(-200, -50))
		letters_container.add_child(letter_node)

func get_lanes():
	return lanes

func _process(_delta):
	if not game_over:
		timer_bar.value = game_timer.time_left

func on_correct_placement():
	correct_count += 1
	if correct_count == target_word.length():
		win_game()

func on_wrong_placement():
	lose_game()

func on_time_up():
	if not game_over:
		lose_game()

func win_game():
	game_over = true
	game_timer.stop()
	print("You win!")

func lose_game():
	game_over = true
	game_timer.stop()
	print("Game over")
