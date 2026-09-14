class_name SkipCinematicPrompt
extends Control

@export var _skip_progress_bar: TextureProgressBar

@export var _prompt_fade_in_duration: float = 0.2
@export var _prompt_visibility_duration: float = 2.0
@export var _prompt_fade_away_duration: float = 1.0

@export var _hold_duration_to_skip: float = 2.0
@export var _hold_drop_duration: float = 0.5

var _prompt_visibility_timer: Timer
var _holding_skip: bool
var _hold_progress_ratio: float

func _ready() -> void:
	_prompt_visibility_timer = Timer.new()
	_prompt_visibility_timer.autostart = false
	_prompt_visibility_timer.one_shot = true
	add_child(_prompt_visibility_timer)
	_prompt_visibility_timer.timeout.connect(_on_prompt_visibility_timer_timeout)

	_skip_progress_bar.max_value = 1.0
	_skip_progress_bar.step = 0.01
	_skip_progress_bar.min_value = 0.0
	
	modulate.a = 0.0

func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey:
		_show_prompt()

func _process(delta: float) -> void:
	if Global.in_ui:
		return

	if Global.tutorial_manager.is_in_skippable_cinematic:
		visible = true
		if Input.is_action_pressed("interact"):
			_show_prompt()
			_holding_skip = true
		else:
			_holding_skip = false

		if _holding_skip:
			_hold_progress_ratio += (1.0 / _hold_duration_to_skip) * delta
		else:
			_hold_progress_ratio -= (1.0 / _hold_drop_duration) * delta
		_hold_progress_ratio = clamp(_hold_progress_ratio, 0.0, 1.0)
		_update_progress_bar()
	else:
		visible = false


func _show_prompt() -> void:
	if _prompt_visibility_timer.time_left == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, _prompt_fade_in_duration)
	_prompt_visibility_timer.wait_time = _prompt_visibility_duration
	_prompt_visibility_timer.start()

func _update_progress_bar() -> void:
	_skip_progress_bar.value = _hold_progress_ratio

func _on_prompt_visibility_timer_timeout() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, _prompt_fade_away_duration)
