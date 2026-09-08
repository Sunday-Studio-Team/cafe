extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.day >= 4:
		queue_free()
