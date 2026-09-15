class_name CinematicBars
extends Control

@export var _top_bar: Control
@export var _bottom_bar: Control

func _ready() -> void:
	_top_bar.offset_transform_enabled = true
	_bottom_bar.offset_transform_enabled = true

	_top_bar.offset_transform_position_ratio.y = -1.0
	_bottom_bar.offset_transform_position_ratio.y = 1.0

func show_bars(animation_duration: float = 1.0) -> void:
	var top_bar_tween: PropertyTweener = create_tween().tween_property(_top_bar, "offset_transform_position_ratio:y", 0.0, animation_duration)
	var bottom_bar_tween: PropertyTweener = create_tween().tween_property(_bottom_bar, "offset_transform_position_ratio:y", 0.0, animation_duration)
	await top_bar_tween.finished

func hide_bars(animation_duration: float = 1.0) -> void:
	var top_bar_tween: PropertyTweener = create_tween().tween_property(_top_bar, "offset_transform_position_ratio:y", -1.0, animation_duration)
	var bottom_bar_tween: PropertyTweener = create_tween().tween_property(_bottom_bar, "offset_transform_position_ratio:y", 1.0, animation_duration)
	await top_bar_tween.finished
