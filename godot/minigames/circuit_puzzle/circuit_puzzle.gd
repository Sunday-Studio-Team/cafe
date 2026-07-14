extends Control

@export var status_label: RichTextLabel
@export var board: Control
@export var line: Line2D
@export var node_container: Control

const NODE_IDS := ["A", "B", "C", "D", "E", "F"]
const PUZZLE_LENGTH := 3

var sequence: Array[String] = []
var current_index := 0
var nodes: Dictionary = {}
var puzzle_finished := false


func _ready() -> void:
	# Hide the mouse just like the other minigames
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	randomize()

	_collect_nodes()

	_start_minigame()


# Find every CircuitNode inside NodeContainer
func _collect_nodes() -> void:

	nodes.clear()

	for child in node_container.get_children():

		if child.has_signal("clicked"):

			nodes[child.node_id] = child

			if !child.clicked.is_connected(_on_node_clicked):
				child.clicked.connect(_on_node_clicked)


# Reset everything and create a new puzzle
func _start_minigame() -> void:
	puzzle_finished = false

	current_index = 0

	sequence.clear()

	status_label.text = ""

	while line.get_point_count() > 0:
		line.remove_point(0)

	# Reset every node
	for node in nodes.values():
		node.reset_node()

	_generate_sequence()

	_update_status()


# Generate a random repair order
func _generate_sequence() -> void:

	var ids := NODE_IDS.duplicate()

	ids.shuffle()

	for i in range(PUZZLE_LENGTH):
		sequence.append(ids[i])


# Display the order on screen
func _update_status() -> void:

	var text := "[center][b]Repair Circuit[/b][/center]\n\n"

	for i in range(sequence.size()):

		text += sequence[i]

		if i < sequence.size() - 1:
			text += "  →  "

	status_label.text = text

# Called when a CircuitNode is clicked
func _on_node_clicked(node_id: String) -> void:

	if puzzle_finished:
		return

	if current_index >= sequence.size():
		return

	if node_id == sequence[current_index]:
		_correct_click(node_id)
	else:
		_wrong_click()


# Handle a correct click
func _correct_click(node_id: String) -> void:

	var node = nodes[node_id]

	node.set_correct()

	# Draw a line to this node
	line.add_point(line.to_local(node.get_center()))

	current_index += 1

	# Puzzle finished
	if current_index >= sequence.size():
		_finish_puzzle()


# Handle a wrong click
func _wrong_click() -> void:

	status_label.text = "[center][color=red][b]Wrong![/b][/color][/center]"

	# Flash every node red
	for node in nodes.values():
		node.set_wrong()

	await get_tree().create_timer(0.4).timeout

	# Start over with a new random puzzle
	_start_minigame()
	
# Puzzle completed successfully
func _finish_puzzle() -> void:
	puzzle_finished = true

	status_label.text = "[center][color=green][b]Machine Fixed![/b][/color][/center]"

	# Disable all nodes
	for node in nodes.values():
		node.disable_node()

	await get_tree().create_timer(0.5).timeout

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	Events.minigame_end.emit()


# Reset button
func _on_reset_button_pressed() -> void:

	_start_minigame()


# Close button
func _on_close_button_pressed() -> void:

	Events.minigame_cancelled.emit()
