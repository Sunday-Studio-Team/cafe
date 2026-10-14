extends Sprite2D
@export var sprite_image: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sprite_image != null:
		texture = sprite_image
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	#print("mouse position", mouse_pos.y)
	global_position.y = mouse_pos.y + 100.0
	#print("global_position.y", global_position.y)

	pass
