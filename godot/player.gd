class_name Player
extends CharacterBody3D

const STRIDE_LENGTH := 0.75

@export var camera: CameraController
@export var aiming_ray: RayCast3D
@export var movement_enabled: bool = true
@export var ingredients_bag: MeshInstance3D
@export var customer_trash: MeshInstance3D
@export var bag_pickup_sound: AudioStreamPlayer3D
# to spawn when we drop the bag
@export var ingredients_bag_scene: PackedScene
@export var customer_trash_scene: PackedScene
@export var sprint_lockout_timer: Timer

@export var pully_ball_scene: PackedScene

var player_status_effects: PlayerStatusEffects

var _walk_move_speed: float
var _sprint_move_speed: float
var _current_move_speed: float

var _is_sprinting: bool
var mouse_sens := 0.1
# the mouse's movement since the last physics frame .
# we get mouse input from _unhandled_input() which is called continuously, so
# we store it here then apply it in the physics process so no movement is
# applied off-sync with physics frames
var mouse_delta: Vector2 = Vector2.ZERO
# vars for footstep sounds
var pos_last_physics_frame: Vector3
var dist_travelled_since_last_step: float
var holding_interactable: bool = false

#when pully ball spawns, starts counting up. keeping track of strength.
var pully_ball_countup: float = 0.0
var pully_ball_instance: Node3D

# we add on top of the ray distance to avoid weird stuff with big interactables
# (whose 'position's may be further away from us than their interactable hitbox)
# NOTE: if we start getting weird flickering while holding interactables, we
# might have to increase this a bit more
@onready var max_interact_dist: float = abs(aiming_ray.target_position.length()) + 1.25


func _ready() -> void:
	Global.player = self
	player_status_effects = PlayerStatusEffects.new(self)
	Events.items_updated.connect(_on_items_updated)
	
	# the aiming ray is a child of the camera (not a direct child of the player)
	# so just enabling exclude_parent doesnt work
	aiming_ray.add_exception(self)

	Events.bag_pickup_animation_grabbed.connect(
		func():
			bag_pickup_sound.play()

			# scuffed 'animation' of bag appearing when we grab it
			ingredients_bag.transparency = 1
			ingredients_bag.scale = Vector3.ZERO

			await Events.viewmodel_animation_finished

			var t := create_tween().set_parallel()
			t.tween_property(ingredients_bag, "scale", Vector3.ONE, 0.25)
			t.tween_property(ingredients_bag, "transparency", 0, 0.25),
	)
	
	Events.trash_pickup_animation_grabbed.connect(
		func():
			bag_pickup_sound.play()

			# scuffed 'animation' of bag appearing when we grab it
			customer_trash.transparency = 1
			customer_trash.scale = Vector3.ZERO

			await Events.viewmodel_animation_finished
			
			var t := create_tween().set_parallel()
			t.tween_property(customer_trash, "scale", Vector3.ONE, 0.25)
			t.tween_property(customer_trash, "transparency", 0, 0.25),
	)



	Global.stamina = Stats.current.max_stamina
	Global.sprint_lockout_timer = sprint_lockout_timer
	sprint_lockout_timer.wait_time = Stats.current.sprint_lockout_time


func _physics_process(delta: float) -> void:
	player_status_effects.process_status_effects(delta)
	
	#handle_mouselook()
	handle_hovered_interactable()
	handle_inspected_shelf_item()
	handle_sprint(delta)
	handle_movement(delta)
	handle_gravity(delta)
	#handle_footstep_sounds()
	#tilt_camera()
	handle_ingredients_bag()
	handle_customer_trash()
	handle_active_items()
	handle_floating_cursor()
	move_and_slide()

func is_sprinting() -> bool:
	return _is_sprinting

#func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		mouse_delta += event.screen_relative * mouse_sens


# this is what decides whether to show the mouse
# (for hovering the tablet ui for more info etc) when holding alt
func handle_floating_cursor() -> void:
	if Input.is_action_pressed("show_cursor"):
		Global.showing_floating_cursor = true
	else:
		Global.showing_floating_cursor = false


func handle_active_items() -> void:
	if Input.is_action_just_pressed("item_menu"):
		if not Global.in_ui or Global.in_active_item_menu:
			var no_active_items_owned := true

			for item in Global.owned_items:
				if item.is_active_item:
					no_active_items_owned = false
					break

			if no_active_items_owned:
				return

			Events.active_item_menu.emit()

	if Input.is_action_just_pressed("use_item") and Global.equipped_item:
		if Global.equipped_item.can_be_used:
			Events.active_item_used.emit(Global.equipped_item)


#func handle_mouselook() -> void:
#	camera.rotation_degrees.x -= mouse_delta.y
#	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
#	
#	rotation_degrees.y -= mouse_delta.x
#	
#	mouse_delta = Vector2.ZERO


func handle_movement(delta: float) -> void:
	if (not movement_enabled or holding_interactable or Global.in_ui):
		velocity = Vector3.ZERO
		return

	var accel: float = Stats.current.player_accel
	var decel: float = Stats.current.player_decel

	# get the input direction (literally a Vector2 of the WASD/stick direction in x and y)
	var input_dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# create a Vector3 of the the input_dir in 3D space
	var input_dir_3d := Vector3(input_dir_2d.x, 0, input_dir_2d.y)

	# multiply our input direction by our transform to get our rotated move direction in 3D space
	var move_dir_3d := transform.basis * input_dir_3d

	# get current velocity without Y so we dont do anything that messes with any gravity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if move_dir_3d.length() > 0.2:
		horizontal_velocity = horizontal_velocity.move_toward(
			move_dir_3d * _current_move_speed,
			accel * delta,
		)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, decel * delta)

	# apply our horizontal velocity (but leave Y alone, the gravity func will handle that)
	velocity = Vector3(horizontal_velocity.x, velocity.y, horizontal_velocity.z)


func handle_gravity(delta: float) -> void:
	velocity.y += get_gravity().y * delta


func handle_hovered_interactable() -> void:
	holding_interactable = false
	var hovered_interactable: Interactable = Global.hovered_interactable

	# if we're somehow hovering an interactable which has been disabled,
	# deleted or moved far away, fix that
	if hovered_interactable != null:
		if camera == null:
			return

		if (
			not hovered_interactable.visible 
			or not hovered_interactable.is_inside_tree()
			or hovered_interactable.global_position.distance_to(camera.global_position) > max_interact_dist
		):
			Global.hovered_interactable = null

	# if we're currently holding interact on something, dont do anything
	# (so we can look around while we hold)
	if (
		hovered_interactable != null and hovered_interactable.hold_to_interact
		and Input.is_action_pressed("interact")
	):
		holding_interactable = true
		return

	var collider = aiming_ray.get_collider()
	if collider is Interactable and collider.visible:
		Global.hovered_interactable = collider
	else:
		Global.hovered_interactable = null

	if Global.in_ui:
		Global.hovered_interactable = null


func handle_inspected_shelf_item() -> void:
	var collider = aiming_ray.get_collider()
	if collider is ShelfItem:
		Global.inspected_shelf_item = collider
	else:
		Global.inspected_shelf_item = null


func handle_sprint(delta: float) -> void:
	var has_roller_skates: bool = false
	for item in Global.owned_items:
		if item.item_id == "roller_skates":
			has_roller_skates = true
			break
	
	if Input.is_action_pressed("sprint") and !has_roller_skates:
		_is_sprinting = true
		if get_last_motion().length() > 0:
			if sprint_lockout_timer.is_stopped():
				Global.stamina -= Stats.current.sprint_stamina_drain_rate * delta
		else:
			Global.stamina += Stats.current.stamina_regen_rate * delta

		if Global.stamina > 0 and sprint_lockout_timer.is_stopped():
			_is_sprinting = true
			_current_move_speed = _sprint_move_speed
		else:
			_is_sprinting = false
			_current_move_speed = _walk_move_speed
			Global.stamina += Stats.current.stamina_regen_rate * delta
	else:
		_is_sprinting = false
		_current_move_speed = _walk_move_speed
		Global.stamina += Stats.current.stamina_regen_rate * delta

	if Global.stamina < 1 and sprint_lockout_timer.is_stopped():
		sprint_lockout_timer.start()


func handle_right_click(_delta: float)-> void:
	#handles pully-ball 
	
	#TODO check if player has item. return if they don't
	
	if (Input.is_action_pressed("right_click") ):
		pass
	
	pass
	


# (unfinished) plays footstep sounds with timing adjusted to speed
func handle_footstep_sounds() -> void:
	if get_last_motion() == Vector3.ZERO:
		dist_travelled_since_last_step = 0
	else:
		dist_travelled_since_last_step += global_position.distance_to(pos_last_physics_frame)

	if dist_travelled_since_last_step >= STRIDE_LENGTH:
		# TODO: play sound
		dist_travelled_since_last_step = 0

	pos_last_physics_frame = global_position


func tilt_camera() -> void:
	const TILT_AMOUNT := 0.25

	var local_velocity: Vector3 = basis.transposed() * velocity
	camera.rotation_degrees.z = -local_velocity.x * TILT_AMOUNT


func handle_ingredients_bag() -> void:
	if (Input.is_action_just_pressed("drop") and Global.holding_ingredients and not Global.in_ui):
		Global.holding_ingredients = false
		var bag_to_drop: RigidBody3D = ingredients_bag_scene.instantiate()
		Global.main_scene.add_child(bag_to_drop)
		bag_to_drop.global_position = camera.global_position + transform.basis * Vector3.FORWARD / 2
		bag_to_drop.apply_impulse(transform.basis * Vector3.FORWARD * 2)

	ingredients_bag.visible = Global.holding_ingredients and not Global.in_ui


func handle_customer_trash() -> void:
	if (Input.is_action_just_pressed("drop") and Global.holding_trash and not Global.in_ui):
		
		Global.holding_trash = false
		#print("heshel", customer_trash_scene)
		var trash_to_drop: RigidBody3D = customer_trash_scene.instantiate()
		Global.main_scene.add_child(trash_to_drop)
		trash_to_drop.global_position = camera.global_position + transform.basis * Vector3.FORWARD / 2
		trash_to_drop.apply_impulse(transform.basis * Vector3.FORWARD * 2)
		
	#print("asdf", ingredients_bag_scene.instantiate().get_class())
	#print(customer_trash_scene.instantiate().get_class())
	customer_trash.visible = Global.holding_trash and not Global.in_ui

func _on_items_updated() -> void:
	player_status_effects.recalculate_status_effects()
