class_name CircuitNode
extends Button

## Sent to CircuitPuzzle when this node is clicked.
signal node_clicked(node: CircuitNode)

@export var node_id: String = "A"

@export var default_color: Color = Color.WHITE
@export var hover_color: Color = Color(1.15, 1.15, 1.15)
@export var correct_color: Color = Color(0.35, 1.0, 0.35)
@export var wrong_color: Color = Color(1.0, 0.35, 0.35)

var completed := false
var enabled := true


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

	reset_node()


func _on_pressed() -> void:
	if !enabled:
		return

	if completed:
		return

	node_clicked.emit(self)


func _on_mouse_entered() -> void:
	if completed:
		return

	modulate = hover_color


func _on_mouse_exited() -> void:
	if completed:
		return

	modulate = default_color


func set_correct() -> void:
	completed = true
	modulate = correct_color


func set_wrong() -> void:
	modulate = wrong_color


func reset_node() -> void:
	completed = false
	enabled = true
	modulate = default_color


func disable() -> void:
	enabled = false


func enable() -> void:
	enabled = true


func get_center() -> Vector2:
	return global_position + size * 0.5
