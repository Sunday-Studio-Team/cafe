extends Node3D

@export var ray: RayCast3D
@export var spotlight: SpotLight3D
@export var rotation_amount: float = 90
@export var rotation_time: float = 3
@export var rotation_pause_length: float = 2
@export var timer: Timer

# we duplicate the ray many times to cover the spotlight cone on startup
# so we store a ref to all the rays here to iterate over them
var all_rays: Array[RayCast3D]
var rotate_tween: Tween

@onready var original_rotation := rotation_degrees


func _ready() -> void:
	create_rays()

	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y + rotation_amount, rotation_time)
	rotate_tween.tween_interval(rotation_pause_length)
	rotate_tween.tween_property(self, "rotation_degrees:y", original_rotation.y - rotation_amount, rotation_time)
	rotate_tween.tween_interval(rotation_pause_length)


func _physics_process(_delta: float) -> void:
	if not timer.is_stopped():
		spotlight.light_color = Color.DIM_GRAY
		return

	var player_in_spotlight := false

	for r in all_rays:
		var collider = r.get_collider()
		if collider == Global.player:
			if Input.is_action_pressed("sprint") and Global.player.get_last_motion() != Vector3.ZERO:
				Events.player_caught_sprinting.emit()
				timer.start()
				Global.score_update_message = "caught running"
				Global.customer_score -= Global.penalty_for_sprinting
			elif (
				Input.is_action_pressed("interact")
				and Global.hovered_interactable != null
				# TODO: think of a better way to identify specific interactables
				# that wont break if things are renamed etc
				and Global.hovered_interactable.display_name.contains("remake drink")
			):
				Events.player_caught_remaking.emit()
				timer.start()
				Global.score_update_message = "caught making drink by hand"
				Global.customer_score -= Global.penalty_for_remaking_drink

			player_in_spotlight = true
			break

# we need both a local and global var here to track if the player is in this
# spotlight AND if theyre in ANY spotlight (otherwise we'd start getting weird
# things like this light flashing red when we enter a separate cameara's fov)
	if player_in_spotlight:
		spotlight.light_color = Color.RED
		Global.player_in_cctv_los = true
	else:
		spotlight.light_color = Color.WHITE


# duplicates our raycast many times, covering roughly the area of the spotlight
func create_rays() -> void:
	# we need to overshoot slightly to account for the sorta
	# halo around the edge of the light
	const ANGLE_OVERSHOOT := 5.0

	for x_rot in range(25, 360, 15):
		for z_rot in range(5, spotlight.spot_angle + ANGLE_OVERSHOOT, 5):
			var new_ray := ray.duplicate() as RayCast3D
			new_ray.rotation_degrees.x += x_rot
			new_ray.rotation_degrees.z += z_rot
			spotlight.add_child(new_ray)
			all_rays.append(new_ray)
