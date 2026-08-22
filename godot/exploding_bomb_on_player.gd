extends Node


@export var exploding_bomb_scene: PackedScene
@export var camera: Camera3D
@export var player: Player

var bomb_instance : Node3D 
var has_exploding_bomb_item: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	handle_right_click(delta)






func handle_right_click(delta: float)-> void:
	#handles bomb spawning, logic w/ bomb timer
	
	if (has_item_checker() == false):
		return
		
	if (Input.is_action_just_pressed("right_click") ):
		if bomb_instance != null:
			return #bomb exists. ignore right click.
			
		else:
			#else, we should plop down the bomb. grab where the player is pointing towards, and plop it down.
			bomb_instance = exploding_bomb_scene.instantiate()
			#
			#
			var throw_direction = -camera.global_transform.basis.z
			add_child(bomb_instance)
			bomb_instance.global_position = camera.global_position + throw_direction / 2
			bomb_instance.find_child("RigidBody3D").apply_impulse(throw_direction*6)
	
	pass


func has_item_checker()->bool:
	has_exploding_bomb_item = false
	for item in Global.owned_items:
		if item.name == "Exploding Bomb":
			has_exploding_bomb_item=true
	return has_exploding_bomb_item
