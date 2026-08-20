# mostly copied from sample project: https://godotengine.org/asset-library/asset/2807
# (basically just handles putting our inputs into a scene on the subviewport
# + some camera stuff)
class_name Gui3D
extends Node3D

const CAM_TWEEN_DUR := 0.25

static var seen_interaction_popup := false

@export var interactable: Interactable
@export var node_viewport: SubViewport
@export var node_quad: MeshInstance3D
@export var node_area: Area3D
@export var cam_spot: Marker3D

var player_using_me := false
# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos2D = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0
# where to put our camera back to when we exit
var cam_trans_b4_enter: Transform3D

#keeps track of where the player was before they interacted w/ machine.
var where_was_player: Transform3D

@onready var machine: Machine = get_parent() as Machine


func _ready():
	node_area.visible = false
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)
	interactable.interacted.connect(
		func():
			# seems weird because we cant interact with Interactables while in_ui
			# anyway but this is actually to stop that CollisionShape blocking
			# our mouse from clicking stuff lul
			node_area.visible = true
			interactable.visible = false
			Global.in_machine_ui = true
			player_using_me = true

			#store where the player was, before they interacted w/ the machine.
			#used when using bomb(), which is in ingredients_refill_minigame.gd
			where_was_player = Global.player.global_transform

			# Showing the popup tutorial when the player uses the machine
			if not seen_interaction_popup:
				seen_interaction_popup = true # Only showing it once
				Global.popups["interaction"].open()
			else:
				pass

			create_tween().tween_property(
				Global.player,
				"global_rotation_degrees",
				machine.global_rotation_degrees,
				0.1,
			)
			create_tween().tween_property(
				Global.player,
				"global_position",
				machine.spot_for_player.global_position,
				0.1,
			)
			var cam: CameraController = Global.player.camera
			cam_trans_b4_enter = cam.transform
			create_tween().tween_property(
				cam,
				"global_transform",
				cam_spot.global_transform,
				CAM_TWEEN_DUR,
			),
	)

	Events.machine_exit_button_pressed.connect(
		func():
			if player_using_me:
				exit(),
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not Global.minigame_active:
		exit()
	if machine.broken_down:
		exit()


func _unhandled_input(event):
	# Check if the event is a non-mouse/non-touch event
	for mouse_event in [
		InputEventMouseButton,
		InputEventMouseMotion,
		InputEventScreenDrag,
		InputEventScreenTouch,
	]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	node_viewport.push_input(event)


func exit() -> void:
	node_area.visible = false
	player_using_me = false

	if not machine.broken_down:
		interactable.visible = true

	if Global.in_machine_ui:
		var cam: CameraController = Global.player.camera
		var target_transform: Transform3D = Global.player.camera_controller_anchor.global_transform
		
		var tween := create_tween()
		
		tween.tween_property(
			cam,
			"global_transform",
			target_transform,
			CAM_TWEEN_DUR,
		)
		await tween.finished
		cam.sync_rotation_to_player()
		Global.in_machine_ui = false


func _mouse_entered_area():
	is_mouse_inside = true


func _mouse_exited_area():
	is_mouse_inside = false


func _mouse_input_event(
	_camera: Camera3D,
	event: InputEvent,
	event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int,
):
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = node_quad.mesh.size

	# Event position in Area3D in world coordinate space.
	var event_pos3D = event_position

	# Current time in seconds since engine start.
	var now: float = Time.get_ticks_msec() / 1000.0

	# Convert position to a coordinate space relative to the Area3D node.
	# NOTE: affine_inverse accounts for the Area3D node's scale, rotation, and position in the scene!
	event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

	# TODO: Adapt to bilboard mode or avoid completely.
	var event_pos2D: Vector2 = Vector2()

	if is_mouse_inside:
		# Convert the relative event position from 3D to 2D.
		event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)

		# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
		# We need to convert it into the following range: -0.5 -> 0.5
		event_pos2D.x = event_pos2D.x / quad_mesh_size.x
		event_pos2D.y = event_pos2D.y / quad_mesh_size.y
		# Then we need to convert it into the following range: 0 -> 1
		event_pos2D.x += 0.5
		event_pos2D.y += 0.5

		# Finally, we convert the position to the following range: 0 -> viewport.size
		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y
		# We need to do these conversions so the event's position is in the viewport's coordinate system.

	elif last_event_pos2D != null:
		# Fall back to the last known event position.
		event_pos2D = last_event_pos2D

	# Set the event's position and global position.
	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

	# Calculate the relative event distance.
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if last_event_pos2D == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos.
		else:
			event.relative = event_pos2D - last_event_pos2D
			event.velocity = event.relative / (now - last_event_time)

	# Update last_event_pos2D with the position we just calculated.
	last_event_pos2D = event_pos2D

	# Update last_event_time to current time.
	last_event_time = now

	# Finally, send the processed input event to the viewport.
	node_viewport.push_input(event)
