extends Node

@export var comic_shader_color_rect: ColorRect
@export var lerp_speed: float = 7.0
@export var shader_range_from_middle: float = 1.6

var comic_shader: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the shader material
	comic_shader = comic_shader_color_rect.material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_radius: float = 3.0
	
	if Global.player.is_sprinting() == true:
		target_radius = shader_range_from_middle
	
	var current_radius: float = comic_shader.get_shader_parameter("Radius")
	var new_radius: float = lerp(current_radius,target_radius,clamp(lerp_speed * delta, 0.0, 1.0))

	comic_shader.set_shader_parameter("Radius",new_radius)
		
