extends Node

@export var normal_cursor: Texture2D
@export var clicked_cursor: Texture2D

@export var normal_pc_cursor: Texture2D
@export var clicked_pc_cursor: Texture2D
# global cursor function for all scenes involving a cursor
# currently hotspot is set to (0,0) in 2d, so that's the top left hand corner
# but can be changed later
@export var normal_cursor_hotspot: Vector2 = Vector2.ZERO
@export var pc_cursor_hotspot: Vector2 = Vector2.ZERO
var pc_active: bool

func _ready() -> void:
	Events.pc_state_change.connect(on_pc_state_change)

	if normal_cursor:
		Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
		Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if pc_active:
			if event.pressed:
				Input.set_custom_mouse_cursor(clicked_pc_cursor, Input.CURSOR_ARROW, pc_cursor_hotspot)
				Input.set_custom_mouse_cursor(clicked_pc_cursor, Input.CURSOR_POINTING_HAND, pc_cursor_hotspot)
			else:
				Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_ARROW, pc_cursor_hotspot)
				Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_POINTING_HAND, pc_cursor_hotspot)
		else:
			if event.pressed:
				Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
				Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)
			else:
				Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
				Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)

func on_pc_state_change():
	if not pc_active:
		pc_active = true
	else:
		pc_active = false
