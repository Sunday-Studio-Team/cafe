extends CanvasLayer

const HOVER_COLOR := Color(0.7, 0.7, 0.7)
const NORMAL_COLOR := Color(1, 1, 1)

@export var popup_id: String = ""
@export var text: Label
@export var title: Label
@export var icon: TextureRect

@onready var close_button: TextureButton = $InputBlocker/TextureButton


func _ready():
	visible = false
	Global.popups[popup_id] = self
	close_button.pressed.connect(close)
	close_button.mouse_entered.connect(_on_close_button_hover)
	close_button.mouse_exited.connect(_on_close_button_unhover)


func open() -> void:
	if OS.has_feature("skip_popups"):
		return

	visible = true
	Global.popup_hint_showing = true
	get_tree().paused = true


func close() -> void:
	visible = false
	Global.popup_hint_showing = false
	get_tree().paused = false


func _on_close_button_hover() -> void:
	close_button.modulate = HOVER_COLOR


func _on_close_button_unhover() -> void:
	close_button.modulate = NORMAL_COLOR
