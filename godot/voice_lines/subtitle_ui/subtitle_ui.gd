class_name SubtitleUi
extends Control

@export var _subtitle_view_packed_scene: PackedScene
@export var _subtitle_views_container: Control
@export var _views_position_default: Control
@export var _views_position_typing_minigame: Control

var _subtitle_views: Array[SubtitleView]
var _voice_line_to_subtitle_view_dict: Dictionary[VoiceLine, SubtitleView]

enum PositionState {
	DEFAULT,
	TYPING_MINIGAME,
}
var _position_state: PositionState

func _ready() -> void:
	Global.voice_line_system.requested_show_voice_line_subtitle.connect(_on_requested_show_voice_line_subtitle)
	Global.voice_line_system.requested_hide_voice_line_subtitle.connect(_on_requested_hide_voice_line_subtitle)
	
	Events.minigame_active.connect(_on_minigame_active)
	Events.minigame_cancelled.connect(_on_minigame_cancelled)
	Events.minigame_end.connect(_on_minigame_end)
	
	_restore_to_default_position()

func _on_requested_show_voice_line_subtitle(voice_line: VoiceLine) -> void:	
	var subtitle_view: SubtitleView = _subtitle_view_packed_scene.instantiate()
	_voice_line_to_subtitle_view_dict[voice_line] = subtitle_view
	_subtitle_views.append(subtitle_view)
	_subtitle_views_container.add_child(subtitle_view)
	subtitle_view.setup(voice_line)

func _on_requested_hide_voice_line_subtitle(voice_line: VoiceLine) -> void:
	if !_voice_line_to_subtitle_view_dict.has(voice_line):
		#printerr("Can't find subtitle view to hide?")
		return
	var subtitle_view: SubtitleView = _voice_line_to_subtitle_view_dict[voice_line]
	_voice_line_to_subtitle_view_dict.erase(voice_line)
	if subtitle_view != null:
		subtitle_view.destroy()

func _on_minigame_active(minigame_name: String) -> void:
	if minigame_name == "Typing":
		_subtitle_views_container.reparent(_views_position_typing_minigame)
		_subtitle_views_container.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_CENTER_BOTTOM)
		_position_state = PositionState.TYPING_MINIGAME

func _on_minigame_cancelled() -> void:
	if _position_state != PositionState.DEFAULT:
		_restore_to_default_position()

func _on_minigame_end() -> void:
	if _position_state != PositionState.DEFAULT:
		_restore_to_default_position()

func _restore_to_default_position() -> void:
	_subtitle_views_container.reparent(_views_position_default)
	_subtitle_views_container.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_CENTER_BOTTOM)
	_position_state = PositionState.DEFAULT
