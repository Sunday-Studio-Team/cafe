
class_name DraggableMop
extends Sprite2D

signal drag_started
signal drag_ended

@export var drag_area: Area2D
@export var bubbles: GPUParticles2D

var drag_collision: CollisionShape2D
var drag_rectangle: RectangleShape2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if drag_area == null:
		push_error("Drag Area has not been assigned.")
		set_process(false)
		set_process_input(false)
		return

	if drag_area.get_child_count() == 0:
		push_error(
			"Drag Area requires a CollisionShape2D child."
		)
		set_process(false)
		set_process_input(false)
		return

	drag_collision = (
		drag_area.get_child(0) as CollisionShape2D
	)

	if drag_collision == null:
		push_error(
			"Drag Area's child must be a CollisionShape2D."
		)
		set_process(false)
		set_process_input(false)
		return

	drag_rectangle = (
		drag_collision.shape as RectangleShape2D
	)

	if drag_rectangle == null:
		push_error(
			"The CollisionShape2D must use RectangleShape2D."
		)
		set_process(false)
		set_process_input(false)
		return

	if bubbles == null:
		push_error(
			"Particle has not been assigned."
		)
		set_process(false)
		set_process_input(false)
		return

	bubbles.emitting = false;

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = (
		event as InputEventMouseButton
	)

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	if mouse_event.pressed:
		if is_mouse_inside_drag_area():
			start_dragging()
	else:
		stop_dragging()


func _process(_delta: float) -> void:
	if not is_dragging:
		return

	if not Input.is_mouse_button_pressed(
		MOUSE_BUTTON_LEFT
	):
		stop_dragging()
		return

	global_position = (
		get_global_mouse_position()
		+ drag_offset
	)


func is_mouse_inside_drag_area() -> bool:
	var local_mouse_position: Vector2 = (
		drag_collision.get_local_mouse_position()
	)

	var half_size: Vector2 = (
		drag_rectangle.size * 0.5
	)

	var inside: bool = (
		absf(local_mouse_position.x) <= half_size.x
		and absf(local_mouse_position.y) <= half_size.y
	)

	print(
		"Mouse: ",
		local_mouse_position,
		" Half size: ",
		half_size,
		" Inside: ",
		inside
	)

	return inside


func start_dragging() -> void:
	if is_dragging:
		return

	is_dragging = true
	bubbles.emitting = true;

	drag_offset = (
		global_position
		- get_global_mouse_position()
	)

	drag_started.emit()


func stop_dragging() -> void:
	if not is_dragging:
		return
	
	bubbles.emitting = false;

	is_dragging = false
	drag_ended.emit()
