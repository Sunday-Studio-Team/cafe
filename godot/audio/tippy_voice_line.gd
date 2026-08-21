extends Resource
class_name TippyVoiceLine

enum TippyLineType {
	shift_start,
	shift_low_time,
	customer_low_time,
	remake_drink,
	machine_make_drink,
	under_goal,
	clean_spill,
	accept_drink
}

@export var audio: AudioStream
@export var condition: TippyLineType

# maybe something for the cd here?
