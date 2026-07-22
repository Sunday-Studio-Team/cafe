extends CanvasLayer
@export var popup_id: String = ""

func _ready():
	visible = false
	Global.popups[popup_id] = self
	
func open() -> void:
	visible = true
	Global.popup_hint_showing = true
	get_tree().paused = true
	
func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		get_tree().paused = false
	
