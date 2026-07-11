extends ColorRect

@export var ingredient_id: String = "orange_box"
@export var ingredient_color: Color = Color.ORANGE

func _ready() -> void:
	color = ingredient_color

func _get_drag_data(_at_position: Vector2):
	var preview := ColorRect.new()
	preview.color = color
	preview.custom_minimum_size = Vector2(60, 60)
	set_drag_preview(preview)

	modulate.a = 0.4
	return {"id": ingredient_id, "source": self}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0
