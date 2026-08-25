extends CharacterBody3D

const GRAB_RANGE: float = 1
const TIME_IN_JAIL: float = 10

@export var nav_agent: NavigationAgent3D
@export var tired_indicator: Label3D
@export var player_kidnap_marker: Marker3D
@export var player_release_marker: Marker3D

enum State {IDLE, CHASING, TIRED, }

var state: State = State.IDLE:
	set = set_state

@onready var starting_pos := global_position
@onready var player := Global.player


func set_state(new_state: State):
	state = new_state
	if new_state == State.CHASING:
		await get_tree().create_timer(20, false).timeout
		set_state(State.TIRED)
	if new_state == State.TIRED:
		await get_tree().create_timer(10, false).timeout
		set_state(State.CHASING)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.day != 5:
		queue_free()

	await Events.shift_started
	set_state(State.CHASING)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == State.CHASING:
		if global_position.distance_to(player.global_position) < GRAB_RANGE:
			# stop moving
			set_state(State.IDLE)

			# send player to jail
			player.global_position = player_kidnap_marker.global_position
			player.reset_physics_interpolation()

			# wait
			await get_tree().create_timer(TIME_IN_JAIL, false).timeout

			# reset tippy in tired state
			global_position = starting_pos
			reset_physics_interpolation()
			set_state(State.TIRED)

			# release player
			player.global_position = player_release_marker.global_position
			player.reset_physics_interpolation()

		nav_agent.target_position = player.global_position
		global_position = global_position.move_toward(nav_agent.get_next_path_position(), delta)
		move_and_slide()

	tired_indicator.visible = state == State.TIRED
