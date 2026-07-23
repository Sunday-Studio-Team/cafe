class_name TabletItemIcon
extends TextureRect

var item: Item


func _physics_process(_delta: float) -> void:
	if item:
		texture = item.icon
		tooltip_text = "%s - %s" % [item.name, item.description]
		show()
	else:
		hide()
