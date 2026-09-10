extends Node

@export var exploding_bomb_scene: PackedScene
@export var camera: Camera3D
@export var player: Player

var bomb_instance: ExplodingBomb
var has_exploding_bomb_item: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_right_click(delta)


# handles bomb spawning, logic w/ bomb timer
func handle_right_click(_delta: float) -> void:
	if not we_have_item():
		return

	if (Input.is_action_just_pressed("right_click")):
		if bomb_instance != null:
			return  # theres already a bomb rn so dont do anything

		else:
			# else, we should plop down the bomb.
			# grab where the player is pointing towards, and plop it down.
			var throw_direction: Vector3 = -camera.global_transform.basis.z

			bomb_instance = exploding_bomb_scene.instantiate()
			bomb_instance.global_position = camera.global_position + throw_direction
			add_child(bomb_instance)

			bomb_instance.apply_impulse(throw_direction * 6)


func we_have_item() -> bool:
	has_exploding_bomb_item = false

	for item in Global.owned_items:
		if item.item_id == "exploding_bomb":
			has_exploding_bomb_item = true
			break
	return has_exploding_bomb_item
