class_name DialogView
extends Control

signal typewriting_finished
signal player_continued

enum State {
	TYPEWRITING,
	WAITING_FOR_PLAYER_CONTINUE,
	DONE,
}

@export var _character_name_label: RichTextLabel
@export var _dialog_text_label: RichTextLabel
@export var _chars_per_second: float = 60

var _state: State = State.DONE
## In seconds.
var _typewriting_duration: float
## In seconds.
var _typewriting_progress: float
var _text_char_count: int

func _process(delta: float) -> void:
	match _state:
		State.TYPEWRITING:
			_typewriting_progress += delta
			_update_visible_chars()
			if _typewriting_progress >= _typewriting_duration:
				_state = State.WAITING_FOR_PLAYER_CONTINUE
				typewriting_finished.emit()
		State.WAITING_FOR_PLAYER_CONTINUE:
			pass
		State.DONE:
			pass
		_:
			printerr("No matching _state.")
			return

func _input(input_event: InputEvent) -> void:
	match _state:
		State.TYPEWRITING:
			if input_event.is_action_pressed("dialog_continue"):
				_typewriting_progress = _typewriting_duration
		State.WAITING_FOR_PLAYER_CONTINUE:
			if input_event.is_action_pressed("dialog_continue"):
				_state = State.DONE
				player_continued.emit()
		State.DONE:
			pass
		_:
			printerr("No matching _state.")
			return		

func show_dialog(dialog_character: DialogCharacter, dialog_text: String) -> void:
	if dialog_character != null:
		var chara_name: String = dialog_character.character_name.to_upper()
		_character_name_label.text = "[b]%s[/b]" % chara_name
	_dialog_text_label.text = dialog_text
	
	_state = State.TYPEWRITING
	_text_char_count = dialog_text.length()
	_typewriting_duration = _calc_typewriting_duration(_text_char_count, _chars_per_second)
	_typewriting_progress = 0.0
	_update_visible_chars()

func _update_visible_chars() -> void:
	var visible_char_ratio: float = _typewriting_progress / _typewriting_duration
	visible_char_ratio = clampf(visible_char_ratio, 0.0, 1.0)
	var visible_char_count: int = ceili(_text_char_count * visible_char_ratio)
	visible_char_count = clampi(visible_char_count, 0, _text_char_count)
	_dialog_text_label.visible_characters = visible_char_count

static func _calc_typewriting_duration(text_length: int, chars_per_second: float) -> float:
	var secs_per_char: float = 1.0 / chars_per_second
	var typewriting_duration: float = text_length * secs_per_char
	return typewriting_duration
