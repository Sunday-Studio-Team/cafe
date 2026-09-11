extends Node

@export var normal_cursor: Texture2D
@export var clicked_cursor: Texture2D

@export var normal_pc_cursor: Texture2D
@export var clicked_pc_cursor: Texture2D
# global cursor function for all scenes involving a cursor
# currently hotspot is set to (0,0) in 2d, so that's the top left hand corner
# but can be changed later
@export var cursor_hotspot: Vector2 = Vector2.ZERO
var pc_active = 0

func _ready() -> void:
	#using a global signal to monitor pc to global cursor switches
	CursorSwitch.pc_state_change.connect(on_pc_state_change)

	if normal_cursor:
			Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, cursor_hotspot)	

func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and pc_active == 0:
		# mouse left key is pressed down
		Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and pc_active == 1: 
		Input.set_custom_mouse_cursor(clicked_pc_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	elif pc_active == 1: 
		Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	elif pc_active == 0: 
		# as soon as mouse left key is released we go back to normal cursor
		Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	else:
		print("none of cursor selection were selected, check to see if image textures are valid")

func on_pc_state_change():
	if pc_active == 0:
		pc_active = 1
	else:
		pc_active = 0
		
	#print(pc_active)
