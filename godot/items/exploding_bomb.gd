extends Node3D


@export var rigid_body: RigidBody3D
@export var collision_shape: CollisionShape3D
@export var csg_sphere: CSGShape3D #placeholder mesh kinda thing
@export var timer: Timer
@export var label: Label3D

var player: Player =null #load this in ready()

var sticky_flag:bool = false
var push_player_in_physics_flag = false
var _bomb_force: Vector3 = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	
	player = Global.player
	if (player == null):
		print('inside exploding_bomb.gd. could not find player... error')
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	
func _physics_process(_delta: float) -> void:
	label.text = str(ceil(timer.time_left))
	if (push_player_in_physics_flag == true):
		push_player_in_physics_flag=false
		player.velocity+= _bomb_force
		player.move_and_slide() 
	
	
func _on_rigid_body_3d_body_entered(body: Node) -> void:
	
	if(body is Player):
		pass
	elif(body is StaticBody3D): #... might be checking incorrectly
		rigid_body.inertia = Vector3.ZERO
		rigid_body.gravity_scale = 0
		rigid_body.lock_rotation = true
		
		#rigid_body.set_freeze_mode(1) #sets freeze mode to kinematic.
		#rigid_body.freeze = true  #freezes rigidbody; stops moving.
		
		#slows down the bomb when it hits the floor 
		rigid_body.linear_damp = 2.8
		rigid_body.angular_damp = 4.5
		
		label.show()
		label.position = Vector3(0, 1, 0)
		
func _on_timer_timeout() -> void:
	#grab the coordinates of player
	#grab the coordinates of bomb [current node]
	
	var player_global_position = player.global_position
	player_global_position.y= 0
	var rigid_body_global_position = rigid_body.global_position
	rigid_body_global_position.y= 0
	var player_to_bomb_vector:Vector3 = player_global_position - rigid_body_global_position
	
	
	
	
	#length of 1 or smaller needs to be about 20
	#length of 4 needs to be about 1
	var max_force = 35
	var min_force = 5
	
	#remap maps the value of player_to_bomb_vector.length, and assumes that it is in the range of [1-4].
	#then, it remaps it onto [max_force, min_force] respectively.
	var some_value = remap(player_to_bomb_vector.length(), 1, 4, max_force, min_force) 
	some_value-= 3
	some_value = clampf(some_value, min_force+1, max_force-2)
	#print("some_value is ", some_value)
	_bomb_force = player_to_bomb_vector.normalized() * some_value
	
	if(_bomb_force.length()>4): # vertically pushes the player a tad.
		_bomb_force.y += 1.25
	else:
		_bomb_force.y += 3.5
	
		
	
	
	#add a tiny bit of z component.
	push_player_in_physics_flag= true
	#player.velocity+= _bomb_force
	#player.move_and_slide() 
	
	await get_tree().create_timer(0.15).timeout
	queue_free()
	
	#item "exploding_bomb" 1
	
	
