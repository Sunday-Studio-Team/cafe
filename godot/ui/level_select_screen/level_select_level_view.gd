class_name LevelSelectLevelView
extends Control

@export var _level_splash_texture_rect: TextureRect
@export var _day_label: RichTextLabel

@export var _level_splashes: Dictionary[int, Texture2D]

func set_splash_day(day: int) -> void:
	var level_splash: Texture2D = _level_splashes[day]
	_level_splash_texture_rect.texture = level_splash
	_day_label.text = str(day)
