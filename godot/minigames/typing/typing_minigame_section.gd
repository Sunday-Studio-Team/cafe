class_name TypingMinigameSection
extends Control

signal section_finished(typing_minigame_section: TypingMinigameSection)

enum State {
	PRE_START,
	PLAYING,
	FINISHED,
}

@export var typing_rich_text_label: RichTextLabel
@export_group("BBCode")
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

var _state: State = State.PRE_START
var _typing_text: String
var _typing_text_completed_index: int

func _ready() -> void:
	_state = State.PRE_START


func _input(input_event: InputEvent) -> void:
	match _state:
		State.PLAYING:
			if input_event is InputEventKey:
				var input_event_key: InputEventKey = input_event as InputEventKey
				var pressed_key_text: String = input_event_key.as_text()
				var pressed_key_text_lowercase: String = pressed_key_text.to_lower()
				var required_key: String = _typing_text[_typing_text_completed_index]
				var required_key_lowercase: String = required_key.to_lower()
				
				if pressed_key_text_lowercase == required_key_lowercase or\
					(pressed_key_text_lowercase.begins_with("Shift + ") and pressed_key_text_lowercase.ends_with(required_key_lowercase)) or\
					(pressed_key_text_lowercase == "space" and required_key_lowercase == " " ) or\
					(pressed_key_text_lowercase == "period" and required_key_lowercase == "." ) or\
					(pressed_key_text_lowercase == "apostrophe" and required_key_lowercase == "'" ) or\
					(pressed_key_text_lowercase == "comma" and required_key_lowercase == "," ):
					
					_typing_text_completed_index += 1
					if _typing_text_completed_index == _typing_text.length():
						_on_section_finished()
					else:
						_update_style_player_reply()
		_:
			pass


func init(typing_text: String) -> void:
	_state = State.PRE_START
	_typing_text = typing_text
	_typing_text_completed_index = 0
	_update_style_player_reply()


func start_section() -> void:
	_state = State.PLAYING


func _update_style_player_reply() -> void:
	var styled_player_reply: String = _typing_text
	
	# Calculate bbcode indices
	
	# Find start of current word
	var current_word_start_index: int = _typing_text_completed_index
	while styled_player_reply[current_word_start_index] != " " and current_word_start_index > 0:
		current_word_start_index -= 1
	
	# Find end of current word
	var current_word_end_index: int = _typing_text_completed_index
	while styled_player_reply[current_word_end_index] != " " and current_word_end_index < styled_player_reply.length()-1:
		current_word_end_index += 1
	
	# If the current letter is a space, replace it with _
	if styled_player_reply[_typing_text_completed_index] == " ":
		styled_player_reply = styled_player_reply.erase(_typing_text_completed_index)
		styled_player_reply = styled_player_reply.insert(_typing_text_completed_index, "_")
	
	var past_words_correct_letters_bbcode_open_index: int = 0
	var past_words_correct_letters_bbcode_close_index: int = current_word_start_index
	
	var current_word_previous_letters_bbcode_open_index: int = current_word_start_index
	var current_word_previous_letters_bbcode_close_index: int = _typing_text_completed_index
	
	var current_word_next_letter_bbcode_open_index: int = _typing_text_completed_index
	var current_word_next_letter_bbcode_close_index: int = _typing_text_completed_index + 1
	
	var current_word_future_letters_bbcode_open_index: int = current_word_next_letter_bbcode_close_index
	var current_word_future_letters_bbcode_close_index: int = current_word_end_index + 1
	
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


func _on_section_finished() -> void:
	_state = State.FINISHED
	section_finished.emit(self)
