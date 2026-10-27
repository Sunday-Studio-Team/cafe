extends TextureRect
signal drink_drop(drink_texture: Texture)
var current_drink: Texture = null
# export this instead later
var is_dragging: bool = false
var dragged_texture: Texture = null
func _get_drag_data(_at_position: Vector2) -> TextureRect:
	# Create a drag preview
	var preview_parent: Control = Control.new()
	var preview: TextureRect = self.duplicate()
	preview_parent.add_child(preview)
	preview.position.x = -(preview.size.x/2)
	preview.position.y = -(preview.size.y/2)
	set_drag_preview(preview_parent)
	
	current_drink = self.texture
	self.texture = null
	return self
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			self.texture = current_drink
			
			drink_drop.emit(self)
