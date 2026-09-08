class_name TabletItemIcon
extends TextureRect

@export var cooldown_progress_bar: TextureProgressBar

var item: Item


func _ready() -> void:
	mouse_entered.connect(func(): Global.hovered_item_icon = self)
	mouse_exited.connect(func(): Global.hovered_item_icon = null)


func _process(_delta: float) -> void:
	if item:
		texture = item.icon
		show()
		if item.is_active_item and not item.can_be_used:
			cooldown_progress_bar.show()
			cooldown_progress_bar.value = (
				(1 - item.active_item_remaining_cooldown / item.active_item_cooldown_at_levels[2]) * 100
			)
		else:
			cooldown_progress_bar.hide()
	else:
		hide()

	if Global.hovered_item_icon == self:
		# this is just WHITE but with an intensity of 2
		# dont ask
		modulate = Color.from_hsv(0.0, 0.0, 1.825, 1.0)
	else:
		modulate = Color.WHITE

	# to stop weird stuff where it might show popup in middle of screen
	# if normal fps mouse mode moves the mouse there without triggering
	# mouse exited signal
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Global.hovered_item_icon = null
