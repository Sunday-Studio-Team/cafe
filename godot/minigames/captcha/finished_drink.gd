extends TextureRect

func _get_drag_data(_at_position: Vector2) -> TextureRect:
	# Create a drag preview
	var preview: TextureRect = self.duplicate()
	set_drag_preview(preview)
	return self
