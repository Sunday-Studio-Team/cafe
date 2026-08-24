@tool
extends Path3D

@export_category("Nodes")
@export var timer: Timer
@export var car_sprite: Sprite3D
@export var path_follow: PathFollow3D
@export_category("Assets")
@export var car_textures: Array[Texture]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(spawn_car)


func _physics_process(_delta: float) -> void:
	car_sprite.global_position = path_follow.global_position


func spawn_car() -> void:
	car_sprite.texture = car_textures.pick_random()

	if randf() < 0.5:
		car_sprite.flip_h = false
		path_follow.progress_ratio = 0
		car_sprite.reset_physics_interpolation()
		create_tween().tween_property(path_follow, "progress_ratio", 1, 10)
	else:
		car_sprite.flip_h = true
		path_follow.progress_ratio = 1
		car_sprite.reset_physics_interpolation()
		create_tween().tween_property(path_follow, "progress_ratio", 0, 10)
