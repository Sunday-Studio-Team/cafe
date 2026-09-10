extends Node

@export var normal_cursor: Texture2D
@export var clicked_cursor: Texture2D

# global cursor function for all scenes involving a cursor
# currently hotspot is set to (0,0) in 2d, so that's the top left hand corner
# but can be changed later
@export var cursor_hotspot: Vector2 = Vector2.ZERO

func _ready() -> void:
	if normal_cursor:
			Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, cursor_hotspot)	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#sprint("cursor input", event)
		if event.pressed:
			# mouse left key is pressed down
			Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_ARROW, cursor_hotspot)
		else:
			# as soon as mouse left key is released we go back to normal cursor
			Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, cursor_hotspot)
