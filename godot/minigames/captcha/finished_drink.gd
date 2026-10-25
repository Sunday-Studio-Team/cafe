extends TextureRect


func _get_drag_data(_at_position: Vector2) -> TextureRect:
	# Create a drag preview
	var preview_parent: Control = Control.new()
	var preview: TextureRect = self.duplicate()
	preview_parent.add_child(preview)
	preview.position.x = -(preview.size.x/2)
	preview.position.y = -(preview.size.y/2)
	set_drag_preview(preview_parent)

	texture = null
	return self
