extends Control

@export var _skipPromptContainer: HBoxContainer
@export var _skip_progress_bar: TextureProgressBar
@export var _prompt_fade_in_duration: float = 0.2
@export var _prompt_visibility_duration: float = 2.0
@export var _prompt_fade_away_duration: float = 1.0
@export var _hold_duration_to_skip: float = 1.0
@export var _hold_drop_duration: float = 0.5
@export var _intro_video: VideoStreamPlayer

var _prompt_visibility_timer: Timer
var _hold_progress_ratio: float
var _holding_skip: bool
var _skipped: bool


func _ready() -> void:
	_prompt_visibility_timer = Timer.new()
	_prompt_visibility_timer.autostart = false
	_prompt_visibility_timer.one_shot = true
	add_child(_prompt_visibility_timer)
	_prompt_visibility_timer.timeout.connect(
		func():
			create_tween().tween_property(_skipPromptContainer, "modulate:a", 0.0, _prompt_fade_away_duration)
	)

	_skip_progress_bar.max_value = 1.0
	_skip_progress_bar.step = 0.01
	_skip_progress_bar.min_value = 0.0
	_skipped = false

	_intro_video.finished.connect(_on_video_finished)


func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
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

	if _hold_progress_ratio >= 1.0 and not _skipped:
		_skipped = true
		_on_video_finished()


func _show_prompt() -> void:
	if _prompt_visibility_timer.time_left == 0:
		create_tween().tween_property(_skipPromptContainer, "modulate:a", 1.0, _prompt_fade_in_duration)
	_prompt_visibility_timer.wait_time = _prompt_visibility_duration
	_prompt_visibility_timer.start()


func _update_skip_progress_bar() -> void:
	_skip_progress_bar.value = _hold_progress_ratio


func _on_video_finished() -> void:
	_intro_video.stop()
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU, true)
