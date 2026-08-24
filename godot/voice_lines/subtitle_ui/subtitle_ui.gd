class_name SubtitleUi
extends Control

@export var _subtitle_view_packed_scene: PackedScene
@export var _subtitle_views_container: Control

var _voice_line_to_subtitle_view_dict: Dictionary[VoiceLine, SubtitleView]

func _ready() -> void:
	Global.voice_line_system.requested_show_voice_line_subtitle.connect(_on_requested_show_voice_line_subtitle)
	Global.voice_line_system.requested_hide_voice_line_subtitle.connect(_on_requested_hide_voice_line_subtitle)


func _on_requested_show_voice_line_subtitle(voice_line: VoiceLine) -> void:
	var subtitle_view: SubtitleView = _subtitle_view_packed_scene.instantiate()
	_voice_line_to_subtitle_view_dict[voice_line] = subtitle_view
	_subtitle_views_container.add_child(subtitle_view)
	subtitle_view.setup(voice_line)

func _on_requested_hide_voice_line_subtitle(voice_line: VoiceLine) -> void:
	if !_voice_line_to_subtitle_view_dict.has(voice_line):
		#printerr("Can't find subtitle view to hide?")
		return
	var subtitle_view = _voice_line_to_subtitle_view_dict[voice_line]
	_voice_line_to_subtitle_view_dict.erase(voice_line)
	subtitle_view.destroy()
