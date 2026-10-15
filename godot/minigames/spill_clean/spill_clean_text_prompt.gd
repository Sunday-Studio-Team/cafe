extends Sprite2D

@export var slide_offset: Vector2 = Vector2(1000, 0)
@export var duration: float = 1.0
var final_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	final_position = global_position
	global_position = final_position + slide_offset
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", final_position, duration)
	pass # Replace with function body.
