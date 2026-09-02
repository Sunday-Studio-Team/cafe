class_name OptionsMenuSliderView
extends Control

signal changed_value(value: float)

@export var _option_name_label: RichTextLabel
@export var _slider: Slider


func _ready() -> void:
	_slider.value_changed.connect(_on_slider_value_changed)

func set_label(label_text: String) -> void:
	_option_name_label.text = label_text

func set_slider_min_max_values(min_value: float, max_value: float, step: float) -> void:
	_slider.min_value = min_value
	_slider.max_value = max_value
	_slider.step = step

func set_slider_value(value: float) -> void:
	_slider.value = value

func _on_slider_value_changed(value: float) -> void:
	changed_value.emit(value)
