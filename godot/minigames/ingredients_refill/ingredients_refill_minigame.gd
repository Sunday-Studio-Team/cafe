extends Node2D

const MOVE_SPEED := 8.5
const NUM_BEANS_TO_SPAWN := 6 #generally, change the timer in BeanSpawnTimer Node when adjusting this; ie make bean*timer = ~2.0s
const MAX_HORIZONTAL_BEAN_FORCE := 800
const MAX_VERTICAL_BEAN_FORCE := 450


@export var cup: CharacterBody2D
@export var bean_scene: PackedScene
@export var screw_bean_scene: PackedScene
@export var golden_bean_scene: PackedScene
@export var bomb_bean_scene: PackedScene
@export var pour_point: Marker2D
@export var bean_spawn_timer: Timer
@export var cup_area: Area2D
@export var cup_boundaries: Area2D
#@export var meter: ProgressBar
@export var meter: TextureProgressBar
@export var bag: Node2D
@export var bean_hit_glasss_sound: AudioStreamPlayer2D
@export var bag_shake_sound: AudioStreamPlayer2D
@export var gain_score_sound: AudioStreamPlayer
@export var normal_face_sprite: CompressedTexture2D
@export var bomb_face_sprite: CompressedTexture2D 
@export var screw_face_sprite: CompressedTexture2D
@export var golden_face_sprite: CompressedTexture2D
@export var normal_visual_effect: CompressedTexture2D
@export var bomb_visual_effect: CompressedTexture2D 
@export var screw_visual_effect: CompressedTexture2D
@export var golden_visual_effect: CompressedTexture2D
@export var face_sprite:Sprite2D
@export var visual_effect:Sprite2D

var beans_in_cup: int = 0
var beans_spawned: int = 0
var gold_bean_spawned: bool = false #guarantees that the refill minigame can only spawn 1 gold bean.
var bomb_bean_spawned: bool = false #guarantees that the refill minigame can only spawn 1 bomb bean.
var screw_bean_spawned: bool = false #guarantees that the refill minigame can only spawn 1 screw bean.
var bag_shake_tween: Tween
var collected_beans: Array[PhysicsBody2D]
var bomb_sound_player: AudioStreamPlayer #requires some setup in ready()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bean_spawn_timer.timeout.connect(spawn_bean)
	cup_area.body_entered.connect(catch_bean)
	cup_area.body_exited.connect(spill_bean)

	bag_shake_tween = create_tween().set_loops()
	bag_shake_tween.tween_property(bag, "position:y", bag.position.y + 30, 0.2)
	bag_shake_tween.tween_property(bag, "position:y", bag.position.y - 30, 0.2)

	cup_boundaries.body_entered.connect(
		func(body):
			if body.is_in_group("beans"):
				bean_hit_glasss_sound.play()
	)

	bomb_sound_player = AudioStreamPlayer.new()
	add_child(bomb_sound_player)

	bomb_sound_player.stream= preload("res://audio/hammer_hit.mp3")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var left_right_input: float = Input.get_vector("move_left", "move_right", "move_forward", "move_back").x
	cup.position.x += left_right_input * MOVE_SPEED
	cup.position.x = clamp(cup.position.x, 350, 1920-350)
	cup.rotation_degrees = lerp(
		cup.rotation_degrees,
		left_right_input * 7,
		delta * 5,
	)

	meter.value = (beans_in_cup as float) / (NUM_BEANS_TO_SPAWN as float)

func spawn_bean()->void:
	
	if beans_spawned >= NUM_BEANS_TO_SPAWN:
		#we have too many beans. end minigame.
		# all beans have spawned; start a timer to end the minigame (signal)
		bean_spawn_timer.stop()
		bag_shake_tween.kill()
		bag_shake_sound.stop()
		await get_tree().create_timer(1.5, false).timeout
		Global.refill_minigame_accuracy = meter.value
		Events.emit_signal("minigame_end")
		print()
		return
	#create a random int from 1-100
	var random_int: int
	var bean: RigidBody2D
	#first do a check for the golden bean
	random_int =  randi_range(1,100)
	#if(beans_spawned==0 and random_int<33): #33
		#spawn_gold_bean(bean)
	#else:
		#spawn_normal_bean(bean)
	#
	#return
	#
	
	if  beans_spawned< 4 and gold_bean_spawned == false : #gold bean case
	
		random_int =  randi_range(1,100)
		if(beans_spawned==0 and random_int<5): #33
			spawn_gold_bean(bean)
		
		elif(beans_spawned==1 and random_int<40): #40
			spawn_gold_bean(bean)
		
		elif(beans_spawned==2 and random_int<60): #67
			spawn_gold_bean(bean)
		
		elif(beans_spawned==3): #100
			spawn_gold_bean(bean)
		else:
			spawn_normal_bean(bean)
		return
	else: #well, a golden bean has spawned in the past; decided between bomb and normal
		random_int =  randi_range(1,100)
		if (bomb_bean_spawned==true):
			spawn_normal_bean(bean)
		else:
			
			if random_int<(25 + beans_spawned *3):
				spawn_bomb_bean(bean)
			else:
				spawn_normal_bean(bean)

	return

func spawn_normal_bean(bean:PhysicsBody2D) -> void:
	bean = bean_scene.instantiate()			
	#bean.scale= Vector2(2,2) #dont do this lol. rigidbodies will attempt to revert this.
	bean.gravity_scale = 0.47
	bean.global_position = pour_point.global_position
	bean.add_to_group("beans")
	add_child(bean)
	bean.apply_impulse(Vector2(randf_range(-MAX_HORIZONTAL_BEAN_FORCE, -MAX_HORIZONTAL_BEAN_FORCE/2.8), randf_range( -MAX_VERTICAL_BEAN_FORCE,-MAX_VERTICAL_BEAN_FORCE/3)))
	bean.rotation_degrees = randf_range(0, 360)
	#bean.apply_torque_impulse(randf_range(-180,180)) #cant get this to work; spins the bean
	beans_spawned += 1

func spawn_gold_bean(bean:PhysicsBody2D) -> void:
	gold_bean_spawned= true
	bean = golden_bean_scene.instantiate()
	bean.gravity_scale = 0.33 + randf_range(-0.15, 0.15)
	bean.global_position = pour_point.global_position
	bean.global_position.x-= 53
	
	bean.global_position.y-= 22 #adding a negative number, puts it vertically north. 
	
	bean.add_to_group("beans")
	add_child(bean)
	bean.apply_impulse(Vector2(randf_range(-MAX_HORIZONTAL_BEAN_FORCE+30, -MAX_HORIZONTAL_BEAN_FORCE/1.8), randf_range(-975,-940)))
	bean.rotation_degrees = randf_range(0, 360)
	#bean.apply_torque_impulse(randf_range(-180,180)) #cant get this to work; spins the bean
	beans_spawned += 1

func spawn_bomb_bean(bean:PhysicsBody2D) -> void:
	bomb_bean_spawned= true
	bean = bomb_bean_scene.instantiate()			
	bean.is_bomb= true
	bean.gravity_scale = 0.2
	bean.global_position = pour_point.global_position
	bean.add_to_group("beans")
	add_child(bean)
	bean.apply_impulse(Vector2(randf_range(-MAX_HORIZONTAL_BEAN_FORCE/1.5,-MAX_HORIZONTAL_BEAN_FORCE/2), -200))
	bean.rotation_degrees = randf_range(0, 360)
	#bean.apply_torque_impulse(randf_range(-180,180)) #cant get this to work; spins the bean
	beans_spawned += 1

func catch_bean(bean: PhysicsBody2D) -> void:
	if not bean.is_in_group("beans"):
		return #not a bean? return.
	var bean_type : String= bean.scene_file_path.get_file() # ex 'coffee_bean.tscn'

	if not collected_beans.has(bean):
		#collected_beans is an array of beans. 
		if "bomb" in bean_type:
			bomb() #also calls Events.emit_signal("minigame_end")
			return
		elif "screw" in bean_type:
			screw() #calls Events.emit_signal("minigame_end")
			#break closest machine
			collected_beans.append(bean)
			return
		elif "gold" in bean_type:
			gold(bean) #calls Events.emit_signal("minigame_end")
			return
		elif "coffee_bean" in bean_type: #this has to be last one checked, because then it is a normal bean
			face_sprite.texture = normal_face_sprite
			visual_effect.texture = normal_visual_effect
			beans_in_cup += 1
			gain_score_sound.play()
			gain_score_sound.pitch_scale += 0.05
			collected_beans.append(bean) #append the bean to collected_beans array


func spill_bean(bean: PhysicsBody2D) -> void:
	if collected_beans.has(bean):
		collected_beans.erase(bean)
		beans_in_cup -= 1
		#print('spill_bean has occured;', bean)


func bomb() ->void:
	face_sprite.texture = bomb_face_sprite
	visual_effect.texture = bomb_visual_effect
	
	var using_machine: Machine = Global.machine_in_use
	if using_machine == null:
		return
	await get_tree().create_timer(0.15, false).timeout
	bomb_sound_player.play()
	#print('line 216. blastplayerfromusingmachine()')
	using_machine.blast_player_from_using_machine()

func screw():
	face_sprite.texture = screw_face_sprite
	visual_effect.texture = screw_visual_effect
	
	var _closest_machine = get_closest_machine_or_null()

	await get_tree().create_timer((NUM_BEANS_TO_SPAWN-2)*bean_spawn_timer.wait_time + bean_spawn_timer.time_left, false).timeout #can we calculate when the minigame will end?
	
	#machine, when calling break_down() has a somewhat variable delay.
	if _closest_machine.broken_down == false: #don't break a machine that is already broken
		_closest_machine.break_down()


func gold(bean: PhysicsBody2D):
	face_sprite.texture = golden_face_sprite
	visual_effect.texture = golden_visual_effect

	beans_in_cup = NUM_BEANS_TO_SPAWN

	#create a for loop; until 
	while len(collected_beans)<NUM_BEANS_TO_SPAWN:
		collected_beans.append(bean)	

	await get_tree().create_timer(0.5, false).timeout

	Global.refill_minigame_accuracy = meter.value
	#print("meter.value; we are in gold()",meter.value)
	Events.emit_signal("minigame_end")


func get_closest_machine_or_null():
	var all_machines = get_tree().get_nodes_in_group("machines")

	var closest_machine = null
	var _player_global_position = Global.player.global_position
	if (all_machines.size() > 0):
		closest_machine = all_machines[0]
		for _machine in all_machines:
			var distance_to_this_machine = _player_global_position.distance_to(_machine.global_position)
			var distance_to_closest_machine = _player_global_position.distance_to(closest_machine.global_position)
			if (distance_to_this_machine < distance_to_closest_machine):
				closest_machine = _machine

	return closest_machine
