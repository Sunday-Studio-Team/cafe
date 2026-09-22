class_name SkipCinematicPrompt
extends Control

@export var _fast_forward_hotkey_label: Label
@export var _fast_forward_active_indicator: Control
@export var _fast_forward_not_active_indicator: Control
@export var _skip_hotkey_label: Label
@export var _skip_progress_bar: TextureProgressBar

@export var _prompt_fade_in_duration: float = 0.2
@export var _prompt_visibility_duration: float = 2.0
@export var _prompt_fade_away_duration: float = 1.0

@export var _fast_forward_multiplier: float = 3.0

@export var _hold_duration_to_skip: float = 1.0
@export var _hold_drop_duration: float = 0.5

var _prompt_visibility_timer: Timer
var _fast_forward_enabled: bool = false
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
	
	_update_fast_forward_indicator()
	_update_skip_progress_bar()

func _input(input_event: InputEvent) -> void:
	if input_event is InputEventKey:
		_show_prompt()

func _process(delta: float) -> void:
	if Global.in_ui:
		visible = false
		if _fast_forward_enabled:
			_fast_forward_enabled = false
			Engine.time_scale = 1.0
			_update_fast_forward_indicator()
		return
	
	if Global.tutorial_manager.is_in_skippable_cinematic:
		visible = true
		
		if _fast_forward_enabled:
			_show_prompt()
		
		if Input.is_action_just_pressed("interact"):
			if _fast_forward_enabled:
				_fast_forward_enabled = false
				Engine.time_scale = 1.0
				_update_fast_forward_indicator()
			else:
				_fast_forward_enabled = true
				Engine.time_scale = _fast_forward_multiplier
				_update_fast_forward_indicator()
		
		if Input.is_action_pressed("use_item"):
			_show_prompt()
			_holding_skip = true
		else:
			_holding_skip = false

		if _holding_skip:
			_hold_progress_ratio += (1.0 / _hold_duration_to_skip) * delta
		else:
			_hold_progress_ratio -= (1.0 / _hold_drop_duration) * delta
		_hold_progress_ratio = clamp(_hold_progress_ratio, 0.0, 1.0)
		_update_skip_progress_bar()
		
		if _hold_progress_ratio >= 1.0:
			Global.tutorial_manager.skip_part_requested = true
			_hold_progress_ratio = 0.0
		
	else:
		visible = false
		
		if _fast_forward_enabled:
			_fast_forward_enabled = false
			Engine.time_scale = 1.0
			_update_fast_forward_indicator()

func _show_prompt() -> void:
	if _prompt_visibility_timer.time_left == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, _prompt_fade_in_duration)
	_prompt_visibility_timer.wait_time = _prompt_visibility_duration
	_prompt_visibility_timer.start()
	_skip_hotkey_label.text = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
	_fast_forward_hotkey_label.text = OS.get_keycode_string(SaveDataManager.get_options_data().interact_action_physical_keycode)

func _update_skip_progress_bar() -> void:
	_skip_progress_bar.value = _hold_progress_ratio

func _update_fast_forward_indicator() -> void:
	if _fast_forward_enabled:
		_fast_forward_active_indicator.visible = true
		_fast_forward_not_active_indicator.visible = false
	else:
		_fast_forward_active_indicator.visible = false
		_fast_forward_not_active_indicator.visible = true

func _on_prompt_visibility_timer_timeout() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, _prompt_fade_away_duration)
