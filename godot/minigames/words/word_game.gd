extends Control

const LANE = preload("res://minigames/words/lane.tscn")
const LETTER = preload("res://minigames/words/letter.tscn")

var words = ["SORRY", "THANKS", "HELLO"]
var chosen_word = ""
var lanes = []
var correct_count = 0
var game_over = false

@onready var lane_container = $CanvasLayer/UI/CenterContainer/Lanes
@onready var letters_container = $CanvasLayer/Letters
@onready var timer_bar = $CanvasLayer/Timer
@onready var game_timer = $GameTimer
@onready var result_label = $CanvasLayer/ResultText

func _ready():
	add_to_group("game_manager")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	chosen_word = words.pick_random()
	visible = true
	
	setup_lanes()
	setup_letters()
	
	game_timer.timeout.connect(on_time_up)
	game_timer.start()
	

func setup_lanes():
	# Each letter needs to have a corresponding box to put it in
	for letter in chosen_word:
		var lane = LANE.instantiate()
		lane.expected_letter = letter
		lane_container.add_child(lane)
		lanes.append(lane)

func setup_letters():
	for letter in chosen_word:
		var letter_node = LETTER.instantiate()
		letter_node.letter_value = letter
		# Letters can fall from anywhere on the top of the screen
		letter_node.position = Vector2(randf_range(200, 1700), randf_range(-200, -50))
		letters_container.add_child(letter_node)

func get_lanes():
	return lanes

func _process(_delta):
	if not game_over:
		timer_bar.value = game_timer.time_left

func on_correct_placement():
	correct_count += 1
	# Checking if player finished the word
	if correct_count == chosen_word.length():
		win_game()
	
func pause():
	# There is probably a better way but this is a good temporary option
	await get_tree().create_timer(0.5).timeout # Letting animations finish playing
	get_tree().paused = true
	
func _physics_process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		Events.minigame_cancelled.emit()
		
func on_time_up():
	if not game_over:
		lose_game()
		
func show_result_text(result_text: String):
	result_label.text = result_text
	result_label.visible = true
	
func win_game():
	game_over = true
	game_timer.stop()
	show_result_text("You Win!")
	pause()
	# Customer gains satisfaction
	_end_minigame()

func lose_game():
	game_over = true
	game_timer.stop()
	show_result_text("You Lose!")
	pause()
	# Customer loses satisfaction
	_end_minigame()
	
func _end_minigame() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Events.minigame_end.emit()
