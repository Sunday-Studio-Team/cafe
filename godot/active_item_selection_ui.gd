extends CanvasLayer
@export var active_item_selection : Control

var active : bool = false

func _read():
	pass

func _process(delta):
	if Input.is_action_just_pressed("Tab"):
		active = not active
	
	if active:
		self.active = true
		active_item_selection.active = true
		self.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		self.active = false
		active_item_selection.active = false
		self.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
