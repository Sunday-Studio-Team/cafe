class_name TabletItemIcon
extends TextureRect

var item: Item


func _ready() -> void:
	mouse_entered.connect(func(): Global.hovered_item_icon = self)
	mouse_exited.connect(func(): Global.hovered_item_icon = null)


func _physics_process(_delta: float) -> void:
	if item:
		texture = item.icon
		show()
	else:
		hide()
