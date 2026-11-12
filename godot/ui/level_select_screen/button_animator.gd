class_name ButtonAnimator
extends Node

@export var _button: BaseButton
@export var _scale_multiplier_hovered: float = 1.2
@export var _scale_multiplier_button_down: float = 0.8
@export var _animation_duration_hovered: float = 0.1
@export var _animation_duration_unhovered: float = 0.1
@export var _animation_duration_button_down: float = 0.1
@export var _animation_duration_button_up: float = 0.1

var _initial_button_offset_scale: Vector2

func _ready() -> void:
	_button.mouse_entered.connect(_on_button_mouse_entered)
	_button.mouse_exited.connect(_on_button_mouse_exited)
	_button.button_down.connect(_on_button_button_down)
	_button.button_up.connect(_on_button_button_up)
	
	_button.offset_transform_enabled = true
	_initial_button_offset_scale = _button.offset_transform_scale

func _on_button_mouse_entered() -> void:
	create_tween().tween_property(_button, "offset_transform_scale", Vector2(_scale_multiplier_hovered, _scale_multiplier_hovered), _animation_duration_hovered)

func _on_button_mouse_exited() -> void:
	create_tween().tween_property(_button, "offset_transform_scale", _initial_button_offset_scale, _animation_duration_unhovered)

func _on_button_button_down() -> void:
	create_tween().tween_property(_button, "offset_transform_scale", Vector2(_scale_multiplier_button_down, _scale_multiplier_button_down), _animation_duration_button_down)

func _on_button_button_up() -> void:
	create_tween().tween_property(_button, "offset_transform_scale", _initial_button_offset_scale, _animation_duration_button_up)
