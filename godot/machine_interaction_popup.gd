extends CanvasLayer

@export var popup_id: String = ""


func _ready():
	visible = false
	Global.popups[popup_id] = self


func _physics_process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close()


func open() -> void:
	visible = true
	Global.popup_hint_showing = true
	get_tree().paused = true


func close() -> void:
	visible = false
	Global.popup_hint_showing = false
	get_tree().paused = false
