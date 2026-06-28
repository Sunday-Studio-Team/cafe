class_name TypingMinigame
extends Control

@export var typing_minigame_contents: Array[TypingMinigameContent]
@export var customer_dialog_container: Control
@export var customer_dialog_rich_text_label: RichTextLabel
@export var customer_dialog_text_tween_duration: float = 0.2
@export var instructions_container: Control
@export var instructions_display_duration: float = 0.1
@export var typing_container: Control
@export var typing_rich_text_label: RichTextLabel
@export var past_words_correct_letters_bbcode_open: String = "[color=green]"
@export var past_words_correct_letters_bbcode_close: String = "[/color]"
@export var current_word_previous_letters_bbcode_open: String = "[b][color=green]"
@export var current_word_previous_letters_bbcode_close: String = "[/color][/b]"
@export var current_word_next_letter_bbcode_open: String = "[b][color=yellow]"
@export var current_word_next_letter_bbcode_close: String = "[/color][/b]"
@export var current_word_future_letters_bbcode_open: String = "[b][color=white]"
@export var current_word_future_letters_bbcode_close: String = "[/color][/b]"
@export var future_words_bbcode_open: String = "[color=gray]"
@export var future_words_bbcode_close: String = "[/color]"
@export var space_hint_character: String = "_"

var minigame_complete: bool
var player_reply: String
var player_reply_completion_index: int
var typing_current_word_first_letter_index: int
var typing_current_word_last_letter_index: int

func _ready() -> void:
	_start_minigame()


func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey and not minigame_complete:
		var input_event_key: InputEventKey = input_event as InputEventKey
		var pressed_key_text: String = input_event_key.as_text()
		var pressed_key_text_lowercase: String = pressed_key_text.to_lower()
		var required_key: String = player_reply[player_reply_completion_index]
		var required_key_lowercase: String = required_key.to_lower()
		
		if pressed_key_text_lowercase == required_key_lowercase or\
			(pressed_key_text_lowercase.begins_with("Shift + ") and pressed_key_text_lowercase.ends_with(required_key_lowercase)) or\
			(pressed_key_text_lowercase == "space" and required_key_lowercase == " " ) or\
			(pressed_key_text_lowercase == "period" and required_key_lowercase == "." ) or\
			(pressed_key_text_lowercase == "apostrophe" and required_key_lowercase == "'" ) or\
			(pressed_key_text_lowercase == "comma" and required_key_lowercase == "," ):
			
			player_reply_completion_index += 1
			if player_reply_completion_index == player_reply.length():
				_finish_minigame()
			else:
				_update_style_player_reply()


func _start_minigame() -> void:
	minigame_complete = false
	player_reply_completion_index = 0

	customer_dialog_container.visible = true
	instructions_container.visible = false
	typing_container.visible = false
	
	# Get a random minigame content resource
	var typing_minigame_contents_index: int = randi_range(0, typing_minigame_contents.size()-1)
	var typing_minigame_content: TypingMinigameContent = typing_minigame_contents[typing_minigame_contents_index]
	
	# Get a random customer dialog
	var typing_minigame_content_customer_dialog_index: int = randi_range(0, typing_minigame_content.possible_customer_dialog.size()-1)
	var customer_dialog: String = typing_minigame_content.possible_customer_dialog[typing_minigame_content_customer_dialog_index]
	
	# Get a random player reply
	var typing_minigame_content_player_reply_index: int = randi_range(0, typing_minigame_content.possible_player_replies.size()-1)
	player_reply = typing_minigame_content.possible_player_replies[typing_minigame_content_player_reply_index]
	
	customer_dialog_rich_text_label.text = customer_dialog
	
	var customer_dialog_tween: Tween = create_tween()
	customer_dialog_rich_text_label.visible_characters = 0
	customer_dialog_tween.tween_property(customer_dialog_rich_text_label, "visible_characters", customer_dialog_rich_text_label.text.length(), customer_dialog_text_tween_duration)
	await customer_dialog_tween.finished
	
	instructions_container.visible = true
	
	var instructions_timer: SceneTreeTimer = get_tree().create_timer(instructions_display_duration)
	await instructions_timer.timeout
	
	typing_container.visible = true
	_update_style_player_reply()


func _finish_minigame() -> void:
	minigame_complete = true
	Events.minigame_end.emit()


func _update_style_player_reply() -> void:
	var styled_player_reply: String = player_reply
	
	# If the current letter is a space, replace it with _
	if styled_player_reply[player_reply_completion_index] == " ":
		styled_player_reply = styled_player_reply.erase(player_reply_completion_index)
		styled_player_reply = styled_player_reply.insert(player_reply_completion_index, "_")
	
	# Calculate bbcode indices
	
	# Find start of current word
	var current_word_start_index: int = player_reply_completion_index
	while styled_player_reply[current_word_start_index] != " " and current_word_start_index > 0:
		current_word_start_index -= 1
	
	# Find end of current word
	var current_word_end_index: int = player_reply_completion_index
	while styled_player_reply[current_word_end_index] != " " and current_word_end_index < styled_player_reply.length()-1:
		current_word_end_index += 1
	
	var past_words_correct_letters_bbcode_open_index: int = 0
	var past_words_correct_letters_bbcode_close_index: int = current_word_start_index
	
	var current_word_previous_letters_bbcode_open_index: int = current_word_start_index
	var current_word_previous_letters_bbcode_close_index: int = player_reply_completion_index
	
	var current_word_next_letter_bbcode_open_index: int = player_reply_completion_index
	var current_word_next_letter_bbcode_close_index: int = player_reply_completion_index + 1
	
	var current_word_future_letters_bbcode_open_index: int = current_word_next_letter_bbcode_close_index
	var current_word_future_letters_bbcode_close_index: int = current_word_end_index
	
	var future_words_bbcode_open_index: int =  current_word_end_index + 1
	if future_words_bbcode_open_index > styled_player_reply.length():
		future_words_bbcode_open_index = styled_player_reply.length()
	var future_words_bbcode_close_index: int = styled_player_reply.length()
	
	# Insert bbcode at indices, while accumulating offset
	
	var offset: int = 0
	
	styled_player_reply = styled_player_reply.insert(past_words_correct_letters_bbcode_open_index, past_words_correct_letters_bbcode_open)
	offset += past_words_correct_letters_bbcode_open.length()
	
	styled_player_reply = styled_player_reply.insert(offset + past_words_correct_letters_bbcode_close_index, past_words_correct_letters_bbcode_close)
	offset += past_words_correct_letters_bbcode_close.length()
	
	styled_player_reply = styled_player_reply.insert(offset + current_word_previous_letters_bbcode_open_index, current_word_previous_letters_bbcode_open)
	offset += current_word_previous_letters_bbcode_open.length()
	
	styled_player_reply = styled_player_reply.insert(offset + current_word_previous_letters_bbcode_close_index, current_word_previous_letters_bbcode_close)
	offset += current_word_previous_letters_bbcode_close.length()

	styled_player_reply = styled_player_reply.insert(offset + current_word_next_letter_bbcode_open_index, current_word_next_letter_bbcode_open)
	offset += current_word_next_letter_bbcode_open.length()
	
	styled_player_reply = styled_player_reply.insert(offset + current_word_next_letter_bbcode_close_index, current_word_next_letter_bbcode_close)
	offset += current_word_next_letter_bbcode_close.length()
	
	if current_word_future_letters_bbcode_open_index <= current_word_future_letters_bbcode_close_index:
		styled_player_reply = styled_player_reply.insert(offset + current_word_future_letters_bbcode_open_index, current_word_future_letters_bbcode_open)
		offset += current_word_future_letters_bbcode_open.length()
		
		styled_player_reply = styled_player_reply.insert(offset + current_word_future_letters_bbcode_close_index, current_word_future_letters_bbcode_close)
		offset += current_word_future_letters_bbcode_close.length()
	
	styled_player_reply = styled_player_reply.insert(offset + future_words_bbcode_open_index, future_words_bbcode_open)
	offset += future_words_bbcode_open.length()
	
	styled_player_reply = styled_player_reply.insert(offset + future_words_bbcode_close_index, future_words_bbcode_close)
	offset += future_words_bbcode_close.length()
	
	typing_rich_text_label.text = styled_player_reply
	
