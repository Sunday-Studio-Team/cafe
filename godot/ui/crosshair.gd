class_name Crosshair
extends Control

var _is_enabled: bool

func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)


func _on_game_options_changed(options_data: OptionsData) -> void:
	match options_data.crosshair_option:
		OptionsData.CrosshairOption.On:
			_is_enabled = true
		OptionsData.CrosshairOption.Off:
			_is_enabled = false
		_:
			printerr("Unhandled crosshair option.")
	_update_visible()


func _physics_process(_delta: float) -> void:
	_update_visible()

func _update_visible() -> void:
	if _is_enabled and !Global.in_ui:
		visible = true
	else:
		visible = false