extends Node

@export var normal_cursor: Texture2D
@export var clicked_cursor: Texture2D

@export var normal_pc_cursor: Texture2D
@export var clicked_pc_cursor: Texture2D

@export var normal_cursor_hotspot: Vector2 = Vector2.ZERO
@export var pc_cursor_hotspot: Vector2 = Vector2.ZERO
var _using_pc: bool


func _ready() -> void:
	Events.pc_state_change.connect(on_pc_state_change)

	Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
	Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)
	Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_CAN_DROP, normal_cursor_hotspot)
	# the only place ive seen this 'forbidden' cursor is while dragging things in the item loadout menu,
	# so i think setting it to the clicked cursor is good
	# (but it might cause issues if that cursor ever gets set somewhere we're not supposed to be clicking . . .)
	#	- jack
	Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_FORBIDDEN, normal_cursor_hotspot)


func _input(input_event: InputEvent) -> void:
	if input_event is InputEventMouseButton and input_event.button_index == MOUSE_BUTTON_LEFT:
		if _using_pc:
			if input_event.pressed:
				Input.set_custom_mouse_cursor(clicked_pc_cursor, Input.CURSOR_ARROW, pc_cursor_hotspot)
				Input.set_custom_mouse_cursor(clicked_pc_cursor, Input.CURSOR_POINTING_HAND, pc_cursor_hotspot)
			else:
				Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_ARROW, pc_cursor_hotspot)
				Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_POINTING_HAND, pc_cursor_hotspot)
		else:
			if input_event.pressed:
				Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
				Input.set_custom_mouse_cursor(clicked_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)
			else:
				Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
				Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)


func on_pc_state_change(using_pc: bool):
	if using_pc:
		_using_pc = true
		Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_ARROW, pc_cursor_hotspot)
		Input.set_custom_mouse_cursor(normal_pc_cursor, Input.CURSOR_POINTING_HAND, pc_cursor_hotspot)
	else:
		_using_pc = false
		Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_ARROW, normal_cursor_hotspot)
		Input.set_custom_mouse_cursor(normal_cursor, Input.CURSOR_POINTING_HAND, normal_cursor_hotspot)
