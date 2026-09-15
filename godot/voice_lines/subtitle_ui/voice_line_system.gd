class_name VoiceLineSystem
extends Node

const NULL_VOICE_LINE_AUDIO_DURATION_BASE: float = 1.5
const NULL_VOICE_LINE_AUDIO_DURATION_PER_CHAR: float = 0.05

## In order of priority.
enum VoiceLinePriorityEnum {
	TUTORIAL,
	CALLOUTS,
}

enum VoiceLineLocationEnum {
	AT_CINEMATIC_CAMERA,
	AROUND_CAFE,
}

signal requested_show_voice_line_subtitle(voice_line: VoiceLine)
signal requested_hide_voice_line_subtitle(voice_line: VoiceLine)

@export var _voice_lines: Array[VoiceLine]
@export var _cinematic_camera_voice_line_player: VoiceLinePlayer
@export var _around_cafe_voice_line_players: Array[VoiceLinePlayer]

var _voice_lines_by_id: Dictionary[String, VoiceLine]
var _currently_playing_voice_line: VoiceLine
var _currently_playing_voice_line_players: Array[VoiceLinePlayer]
var _currently_playing_voice_line_priority: VoiceLinePriorityEnum

func _init() -> void:
	Global.voice_line_system = self

func setup() -> void:
	# Process voice lines for faster referencing.
	for voice_line in _voice_lines:
		_voice_lines_by_id[voice_line.voice_line_id] = voice_line
	
func play_voice_line(voice_line_id: String, location: VoiceLineSystem.VoiceLineLocationEnum, priority: VoiceLineSystem.VoiceLinePriorityEnum) -> void:
	var voice_line: VoiceLine = _get_voice_line_by_id(voice_line_id)
	if voice_line == null:
		printerr("Missing voice line! ID %s" % voice_line_id)
		return
	
	if _currently_playing_voice_line != null:
		# Don't interrupt if current voice line is priority 
		if _currently_playing_voice_line_priority < priority:
			return
		
		# Interrupt currently playing voice line.
		for player in _currently_playing_voice_line_players:
			player.interrupt_voice_line()
		_currently_playing_voice_line_players.clear()
		_currently_playing_voice_line = null

	match location:
		VoiceLineLocationEnum.AT_CINEMATIC_CAMERA:
			_currently_playing_voice_line_players.append(_cinematic_camera_voice_line_player)
		VoiceLineLocationEnum.AROUND_CAFE:
			_currently_playing_voice_line_players.append_array(_around_cafe_voice_line_players)
		_:
			printerr("Unknown VoiceLineLocationEnum?")
			return

	_currently_playing_voice_line = voice_line
	_currently_playing_voice_line_priority = priority
	
	requested_show_voice_line_subtitle.emit(_currently_playing_voice_line)
	for player in _currently_playing_voice_line_players:
		player.play_voice_line(_currently_playing_voice_line)
	
	# Just assume all are done if the first player is done.
	var _first_playing_voice_line_player: VoiceLinePlayer = _currently_playing_voice_line_players[0]
	await _first_playing_voice_line_player.finished_playing_voice_line
	requested_hide_voice_line_subtitle.emit(_currently_playing_voice_line)

static func calculate_missing_audio_stream_caption_duration(voice_line: VoiceLine) -> float:
	var duration: float = NULL_VOICE_LINE_AUDIO_DURATION_BASE + (voice_line.subtitle_en.length() * NULL_VOICE_LINE_AUDIO_DURATION_PER_CHAR)
	return duration

func _get_voice_line_by_id(voice_line_id: String) -> VoiceLine:
	if !_voice_lines_by_id.has(voice_line_id):
		return null
	var voice_line: VoiceLine = _voice_lines_by_id[voice_line_id]
	if voice_line == null:
		return null
	# Soft duplicate it so we can differentiate individual playback events of the same voice_line
	voice_line = voice_line.duplicate()
	return voice_line
