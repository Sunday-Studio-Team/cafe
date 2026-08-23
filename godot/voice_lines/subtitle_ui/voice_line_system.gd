class_name VoiceLineSystem
extends Node

signal requested_show_voice_line_subtitle(voice_line: VoiceLine)
signal requested_hide_voice_line_subtitle(voice_line: VoiceLine)

@export var _voice_lines: Array[VoiceLine]
@export var _voice_line_no_location_player: VoiceLineNoLocationPlayer

var _voice_lines_by_id: Dictionary[String, VoiceLine]
var _playing_voice_line_location_player: VoiceLineLocationPlayer

func _init() -> void:
	Global.voice_line_system = self
	
func _ready() -> void:
	# Process voice lines for faster referencing.
	for voice_line in _voice_lines:
		_voice_lines_by_id[voice_line.voice_line_id] = voice_line

func play_voice_line_at_location(voice_line_id: String, voice_line_location: VoiceLineLocation) -> void:
	# Interrupt any existing playing voice line locations
	if _playing_voice_line_location_player != null:
		_playing_voice_line_location_player.interrupt_voice_line()
		await _playing_voice_line_location_player.finished_playing_voice_line
	
	var voice_line: VoiceLine = _get_voice_line_by_id(voice_line_id)
	var location_player: VoiceLineLocationPlayer = voice_line_location.internal_setup_voice_line_at_location(voice_line)
	requested_show_voice_line_subtitle.emit(voice_line)
	location_player.play_voice_line(voice_line)
	_playing_voice_line_location_player = location_player
	await location_player.finished_playing_voice_line
	_playing_voice_line_location_player = null
	requested_hide_voice_line_subtitle.emit(voice_line)

## Play a voice line without a specific location, with its subtitle.
func play_voice_line_no_location(voice_line_id: String) -> void:
	var voice_line: VoiceLine = _get_voice_line_by_id(voice_line_id)
	requested_show_voice_line_subtitle.emit(voice_line)
	_voice_line_no_location_player.play_voice_line(voice_line)
	await _voice_line_no_location_player.finished_playing_voice_line
	requested_hide_voice_line_subtitle.emit(voice_line)

func _get_voice_line_by_id(voice_line_id: String) -> VoiceLine:
	if !_voice_lines_by_id.has(voice_line_id):
		return null
	var voice_line: VoiceLine = _voice_lines_by_id[voice_line_id]
	if voice_line == null:
		return null
	# Soft duplicate it so we can differentiate individual playback events of the same voice_line
	voice_line = voice_line.duplicate()
	return voice_line
