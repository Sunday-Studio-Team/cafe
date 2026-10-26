extends CharacterBody3D

@export var jumpscareMax: int = 1
var jumpscareCount: int = 0

@export var tippyMoveSpeed : int = 2
var footstep_speaker : AudioStreamPlayer3D
var staring_speaker : AudioStreamPlayer3D

@export var cooldownRange: Array[int] = []
var cooldownTime: int
@export var staringTime: int
@export var staringPosition: int

@export var locations: Array[Marker3D] = []
var targetPosition
# number is position in array
var number = -1

func _ready() -> void:
	footstep_speaker = $Footsteps
	staring_speaker = $Staring
	_boss_begins_walking()

# if at the beginning, waits a certain amt of time before continueing
# this is used to set a time before he starts walking out
func _boss_begins_walking():
	if (number == -1):
		cooldownTime = randi_range(cooldownRange[0], cooldownRange[1])
		print ("cooldown time: ", cooldownTime)
		await get_tree().create_timer(cooldownTime).timeout
	_boss_walks_around()

# walks through the array of locations
# will pause at the stare location before continuing
func _boss_walks_around() -> void:
	if jumpscareCount < jumpscareMax:
		# sets next location in array to walk to
		if number < (locations.size() - 1):
			number += 1
			print("target position ", number)
		else:
			# reset
			number = -1
			jumpscareCount += 1
			print("jumpscare: ", jumpscareCount, " out of ", jumpscareMax)
		targetPosition = locations[number].global_position
		await move_to(targetPosition)
		
		# stands still at staring position, before going to next location
		if number == staringPosition:
			print("staring")
			staring_speaker.play()
			await get_tree().create_timer(staringTime).timeout
		_boss_begins_walking()

# smoothly move to a location
# NOTE: loc should be a global position
func move_to(loc: Vector3) -> void:
	var dur := global_position.distance_to(loc) / tippyMoveSpeed
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", loc, dur)
	footstep_speaker.play()
	await t.finished
	footstep_speaker.stop()
	
