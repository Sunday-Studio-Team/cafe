extends Panel

var expected_letter: String = ""
var is_filled: bool = false

func try_place(letter_node) -> bool:
	if is_filled:
		return false
	if letter_node.letter_value == expected_letter:
		is_filled = true
		flash(Color.GREEN)
		return true
	else:
		flash(Color.RED)
		return false

func flash(color: Color):
	modulate = color
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
