class_name TippyCalloutsManager
extends Node

const TIPPY_CALLOUT_MIN_COOLDOWN: float = 5.0
const TIPPY_CALLOUT_MAX_COOLDOWN: float = 10.0

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

@export var _tippy_line_array_shift_start: Array[VoiceLine]
@export var _tippy_line_array_shift_low_time: Array[VoiceLine]
@export var _tippy_line_array_customer_low_time: Array[VoiceLine]
@export var _tippy_line_array_remake_drink: Array[VoiceLine]
@export var _tippy_line_array_machine_make_drink: Array[VoiceLine]
@export var _tippy_line_array_under_goal: Array[VoiceLine]
@export var _tippy_line_array_clean_spill: Array[VoiceLine]
@export var _tippy_line_array_accept_drink: Array[VoiceLine]

var _is_playing_line: bool
var _tippy_voice_timer: Timer

func _ready() -> void:
	_tippy_voice_timer = Timer.new()
	_tippy_voice_timer.autostart = false
	_tippy_voice_timer.one_shot = true
	add_child(_tippy_voice_timer)
	
	# Add tippy voice lines
	Events.shift_started.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.shift_start)
	)
	Events.low_time_warning.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.shift_low_time)
	)
	Events.customer_low_time_warning.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.customer_low_time)
	)
	Events.order_remaking_drink.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.remake_drink)
	)
	Events.machine_making_drink.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.machine_make_drink)
	)
	Events.under_money_goal.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.under_goal)
	)
	Events.spill_clean_done.connect(func():
		play_tippy_callout(TippyCalloutsManager.TippyLineType.clean_spill)
	)
	Events.order_approved.connect(func(_customer: Customer):
		play_tippy_callout(TippyCalloutsManager.TippyLineType.accept_drink)
	)

func play_tippy_callout(tippy_line_type: TippyLineType) -> void:
	if _is_playing_line:
		return
	
	if !_tippy_voice_timer.is_stopped():
		return
	
	var voice_line_array: Array[VoiceLine] = _get_tippy_callout_array_by_type(tippy_line_type)
	if voice_line_array.is_empty():
		printerr("Missing Tippy voice line!")
		return
	
	var chance_play: float = randf_range(0.0, 1.0)
	if tippy_line_type == TippyCalloutsManager.TippyLineType.shift_low_time:
		chance_play += 0.25
	
	if chance_play >= 0.5 or tippy_line_type == TippyCalloutsManager.TippyLineType.shift_start:
		var random_voice_line: VoiceLine = voice_line_array.pick_random()
		_is_playing_line = true
		await Global.voice_line_system.play_voice_line_no_location(random_voice_line.voice_line_id)
		_is_playing_line = false
		_tippy_voice_timer.start(randf_range(TIPPY_CALLOUT_MIN_COOLDOWN, TIPPY_CALLOUT_MAX_COOLDOWN))

func _get_tippy_callout_array_by_type(tippy_line_type: TippyLineType) -> Array[VoiceLine]:
	match tippy_line_type:
		TippyLineType.shift_start:
			return _tippy_line_array_shift_start
		TippyLineType.shift_low_time:
			return _tippy_line_array_shift_low_time
		TippyLineType.customer_low_time:
			return _tippy_line_array_customer_low_time
		TippyLineType.remake_drink:
			return _tippy_line_array_remake_drink
		TippyLineType.machine_make_drink:
			return _tippy_line_array_machine_make_drink
		TippyLineType.under_goal:
			return _tippy_line_array_under_goal
		TippyLineType.clean_spill:
			return _tippy_line_array_clean_spill
		TippyLineType.accept_drink:
			return _tippy_line_array_accept_drink
		_:
			printerr("Unhandled case!")
			return []
