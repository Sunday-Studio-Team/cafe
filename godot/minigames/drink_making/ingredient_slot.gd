extends Control

var ingredient_id: String = ""
var ingredient_name: String = ""
var ingredient_color: Color = Color.WHITE

@export var slot_size: Vector2 = Vector2(110, 120)

var _swatch: ColorRect
var _label: Label


func _ready() -> void:
	custom_minimum_size = slot_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	_swatch = ColorRect.new()
	_swatch.custom_minimum_size = Vector2(slot_size.x - 20, slot_size.y - 44)
	vbox.add_child(_swatch)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_label)

	_refresh_visuals()


## Call right after instancing, before or after adding to the tree.
func setup(data: Dictionary) -> void:
	ingredient_id = data.id
	ingredient_name = data.name
	ingredient_color = data.color
	_refresh_visuals()


func _refresh_visuals() -> void:
	if _swatch:
		_swatch.color = ingredient_color
	if _label:
		_label.text = ingredient_name


func _get_drag_data(_at_position: Vector2):
	if ingredient_id == "":
		return null

	var preview := ColorRect.new()
	preview.color = ingredient_color
	preview.custom_minimum_size = Vector2(64, 64)
	set_drag_preview(preview)

	modulate.a = 0.35
	return {"id": ingredient_id, "name": ingredient_name, "source": self}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0


func play_wrong_shake() -> void:
	var tween := create_tween()
	var start_x := position.x
	tween.tween_property(self, "position:x", start_x - 8, 0.05)
	tween.tween_property(self, "position:x", start_x + 8, 0.05)
	tween.tween_property(self, "position:x", start_x, 0.05)


func play_correct_and_disable() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.25, 0.25)
