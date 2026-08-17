extends Panel

var expected_letter: String = ""
var is_filled: bool = false

func try_place(letter_node) -> bool:
	if is_filled:
		return false
	if letter_node.letter_value == expected_letter:
		is_filled = true
		flash(Color.GREEN)

		letter_node.get_parent().remove_child(letter_node)
		add_child(letter_node)
		
		# Center the letter within the lane
		letter_node.anchor_left = 0
		letter_node.anchor_top = 0
		letter_node.anchor_right = 1
		letter_node.anchor_bottom = 1
		letter_node.offset_left = 0
		letter_node.offset_top = 0
		letter_node.offset_right = 0
		letter_node.offset_bottom = 0
		
		return true
	else:
		flash(Color.RED)
		return false

func flash(color: Color):
	modulate = color
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
