extends Node2D

const MOVE_SPEED := 6.7
const BEANS_TO_SPAWN := 5
const LEFT_RIGHT_FORCE := 250

@export var cup: CharacterBody2D
@export var bean_scene: PackedScene
@export var screw_bean_scene: PackedScene
@export var golden_bean_scene: PackedScene
@export var bomb_bean_scene: PackedScene
@export var pour_point: Marker2D
@export var bean_spawn_timer: Timer
@export var cup_area: Area2D
@export var cup_boundaries: Area2D
@export var meter: ProgressBar
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

var beans_in_cup := 0
var beans_spawned := 0
var bomb_bean_spawned = false #guarantees that the refill minigame can only spawn 1 bomb bean.
var screw_bean_spawned = false #guarantees that the refill minigame can only spawn 1 screw bean.
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
	var left_right_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").x
	cup.position.x += left_right_input * MOVE_SPEED
	cup.position.x = clamp(cup.position.x, 600, 1300)
	cup.rotation_degrees = lerp(
		cup.rotation_degrees,
		left_right_input * 7,
		delta * 5,
	)

	meter.value = float(beans_in_cup) / float(BEANS_TO_SPAWN)


func spawn_bean() -> void:
	# let's... create a random int from 1-100
	var random_int: int = randi_range(1,100)

	if beans_spawned < BEANS_TO_SPAWN: #BEANS_TO_SPAWN decrements from ~5 to 0
		var bean: RigidBody2D
		if random_int<12 and bomb_bean_spawned == false:
			bean = bomb_bean_scene.instantiate()
			bomb_bean_spawned = true #guarantees that the refill minigame can only spawn 1 bomb  bean.

		#elif random_int>=10 and random_int<20 and screw_bean_spawned == false:
		#	bean = screw_bean_scene.instantiate()
		#	screw_bean_spawned = true #guarantees that the refill minigame can only spawn 1 screw bean.

		elif random_int>=20 and random_int<35 :
			bean = golden_bean_scene.instantiate()
		else: #we removed the screw, but rng for screw now goes to here.
			bean = bean_scene.instantiate()

		bean.global_position = pour_point.global_position
		bean.add_to_group("beans")
		add_child(bean)
		bean.apply_impulse(Vector2(randf_range(-LEFT_RIGHT_FORCE, LEFT_RIGHT_FORCE), 0))
		bean.rotation_degrees = randf_range(0, 360)
		#bean.apply_torque_impulse(randf_range(-180,180)) #cant get this to work; spins the bean
		beans_spawned += 1
	else:
		# all beans have spawned; start a timer to end the minigame (signal)
		bean_spawn_timer.stop()

		Global.refill_minigame_accuracy = meter.value
		bag_shake_tween.kill()
		bag_shake_sound.stop()
		await get_tree().create_timer(1.5, false).timeout
		Events.emit_signal("minigame_end")


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


func bomb() ->void:
	face_sprite.texture = bomb_face_sprite
	visual_effect.texture = bomb_visual_effect

	var closest_machine = get_closest_machine_or_null()
	if closest_machine == null: #error handling
		return

	#play a sound
	bomb_sound_player.play()
	await get_tree().create_timer(0.5, false).timeout

	var _machine_global_position = closest_machine.global_position

	#machine has a child called "3DGui", node is Gui3D
	var _3dgui: Gui3D = closest_machine.find_child("3DGui") 
	var _player_global_position = _3dgui.where_was_player.origin


	Events.emit_signal("minigame_end")

	# draw a line between player, and machine.
	var _line = (_player_global_position -  _machine_global_position).normalized()*9.5

	var machine_name = str(closest_machine).to_lower()

	# incredibly janky way. the 'better way' includes the use of dot products but i aint got time for that
	if("machine2" in machine_name or "machine3" in machine_name): #2 and 3 are the first machines.
		_line.x *=2 #makes player go sideways more...? #works for first 2 machines; machine3 and machine2.
	else:
		_line.z*=2

	# there is some code that disables movement, when we are in UI interacting w/ machine.
	# let's explicitly exit the UI before we push/slide the player.
	if _3dgui.player_using_me:
		_3dgui.exit()

	# apply velocity to player
	Global.player.velocity = _line
	Global.player.move_and_slide()


func screw():
	face_sprite.texture = screw_face_sprite
	visual_effect.texture = screw_visual_effect
	
	var _closest_machine = get_closest_machine_or_null()

	await get_tree().create_timer((BEANS_TO_SPAWN-2)*bean_spawn_timer.wait_time + bean_spawn_timer.time_left, false).timeout #can we calculate when the minigame will end?
	
	#machine, when calling break_down() has a somewhat variable delay.
	if _closest_machine.broken_down == false: #don't break a machine that is already broken
		_closest_machine.break_down()


func gold(bean: PhysicsBody2D):
	face_sprite.texture = golden_face_sprite
	visual_effect.texture = golden_visual_effect

	beans_in_cup = 5
	#create a for loop; until 
	while len(collected_beans)<5:
		collected_beans.append(bean)	

	await get_tree().create_timer(0.5, false).timeout #has to be less than bean timer!
	Global.score_update_message = "earned" 
	Global.daily_cafe_money += 1

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
