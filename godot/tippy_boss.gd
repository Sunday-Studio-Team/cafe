class_name TippyBoss
extends CharacterBody3D

const GRAB_RANGE: float = 1
const TIME_IN_JAIL: float = 10

@export var customer_area: Area3D
@export var back_room_enter_trigger: Area3D
@export var jumpscare_fade_rect: ColorRect
@export var nav_agent: NavigationAgent3D
@export var tired_indicator: Label3D
@export var player_kidnap_marker: Marker3D
# confusing names i know .
# this times how long he runs before he gets tired
@export var tired_timer: Timer
# and this times how long he 'sleeps' before waking up once he gets tired
@export var sleep_timer: Timer
@export var stun_timer: Timer

enum State {IDLE, CHASING, TIRED, ZAPPED}

var state: State = State.IDLE:
	set = set_state
var player_in_customer_area: bool = false

@onready var starting_pos := global_position
@onready var player: Player = Global.player


func set_state(new_state: State):
	tired_indicator.text = ""
	tired_timer.stop()
	sleep_timer.stop()
	stun_timer.stop()

	state = new_state

	if new_state == State.CHASING:
		tired_timer.start()
		await tired_timer.timeout
		set_state(State.TIRED)
	elif new_state == State.TIRED:
		tired_indicator.text = "😴"
		sleep_timer.start()
		await sleep_timer.timeout
		set_state(State.CHASING)
	elif new_state == State.ZAPPED:
		tired_indicator.text = "⚡️"
		stun_timer.start()
		await stun_timer.timeout
		set_state(State.CHASING)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.tippy_boss = self

	if Global.day != 5:
		queue_free()
	
	customer_area.body_entered.connect(
		func(body: PhysicsBody3D):
			if body == Global.player:
				player_in_customer_area = true
	)
	customer_area.body_exited.connect(
		func(body: PhysicsBody3D):
			if body == Global.player:
				player_in_customer_area = false
	)	

	Events.shift_started.connect(
		func():
		back_room_enter_trigger.body_entered.connect(
			func(body: PhysicsBody3D):
				if body == Global.player:
					set_state(State.CHASING),
					ConnectFlags.CONNECT_ONE_SHOT
	)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == State.CHASING:
		if global_position.distance_to(player.global_position) < GRAB_RANGE:
			# stop moving + block detection of duplicate grabs
			set_state(State.IDLE)

			# send player to jail
			await create_tween().tween_property(jumpscare_fade_rect, "modulate", Color.WHITE, 0.25).finished
			player.global_position = player_kidnap_marker.global_position
			player.reset_physics_interpolation()
			create_tween().tween_property(jumpscare_fade_rect, "modulate", Color.TRANSPARENT, 0.25)
			Events.tippy_boss_kidnapped_player.emit()

			# wait
			await get_tree().create_timer(TIME_IN_JAIL, false).timeout

			# reset tippy
			global_position = starting_pos
			reset_physics_interpolation()

			# release player
			Events.tippy_boss_released_player.emit()
			player.reset_physics_interpolation()

			# start tippy again in tired state once player exits office
			await Events.player_left_office
			set_state(State.TIRED)

		if not player_in_customer_area:
			nav_agent.target_position = player.global_position
		else:
			nav_agent.target_position = starting_pos
		global_position = global_position.move_toward(nav_agent.get_next_path_position(), delta)
		move_and_slide()

	tired_indicator.visible = state == State.TIRED or state == State.ZAPPED
