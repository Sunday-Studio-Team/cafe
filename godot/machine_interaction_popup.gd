extends CanvasLayer
@export var popup_id: String = ""

func _ready():
	visible = false
	Global.popups[popup_id] = self
	
func open() -> void:
	visible = true
	Global.popup_hint_showing = true
	get_tree().paused = true
	
func close() -> void:
	visible = false
	Global.popup_hint_showing = false
	get_tree().paused = false
	
func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	
