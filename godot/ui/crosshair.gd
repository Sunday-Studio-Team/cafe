class_name Crosshair
extends Control


func _ready() -> void:
	Events.game_options_changed.connect(_on_game_options_changed)


func _on_game_options_changed(options_data: OptionsData) -> void:
	match options_data.crosshair_option:
		OptionsData.CrosshairOption.On:
			visible = true
		OptionsData.CrosshairOption.Off:
			visible = false
		_:
			printerr("Unhandled crosshair option.")


func _physics_process(_delta: float) -> void:
	visible = not Global.in_ui
