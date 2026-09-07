class_name LevelSelectScreen
extends CanvasLayer

@export var _previous_day_button: BaseButton
@export var _next_day_button: BaseButton
@export var _play_button: BaseButton
@export var _back_to_main_menu_button: BaseButton

@export var _page_spread: LevelSelectPageSpread
@export var _page_sub_viewport_a: SubViewport
@export var _level_view_a: LevelSelectLevelView
@export var _page_sub_viewport_b: SubViewport
@export var _level_view_b: LevelSelectLevelView

@export var _fake_flip_page: LevelSelectFakeFlipPage
@export var _page_flip_animation_player: AnimationPlayer
@export var _flip_to_next_animation_name: StringName

var _animating: bool = false
var _finished_selection: bool = false

var _day: int = 0

var _old_page_sub_viewport: SubViewport
var _old_page_level_view: LevelSelectLevelView
var _new_page_sub_viewport: SubViewport
var _new_page_level_view: LevelSelectLevelView

func _ready() -> void:
	_previous_day_button.pressed.connect(_on_previous_day_button_pressed)
	_next_day_button.pressed.connect(_on_next_day_button_pressed)
	_play_button.pressed.connect(_on_play_button_pressed)
	_back_to_main_menu_button.pressed.connect(_on_back_to_main_menu_button_pressed)
	
	_old_page_sub_viewport = _page_sub_viewport_a
	_old_page_level_view = _level_view_a
	_new_page_sub_viewport = _page_sub_viewport_b
	_new_page_level_view = _level_view_b
	
	_page_spread.set_left_page_view(_old_page_sub_viewport)
	_page_spread.set_right_page_view(_old_page_sub_viewport)
	
	_fake_flip_page.visible = false
	
	# Load up the latest unlocked day
	_day = SaveDataManager.save_data.latest_unlocked_day
	_old_page_level_view.set_splash_day(_day)
	
	_update_prev_next_buttons()
	
	Global.in_level_select_menu = true

func _on_play_button_pressed() -> void:
	if _finished_selection:
		return
	_finished_selection = true
	
	Global.in_level_select_menu = false
	Global.day = _day
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)

func _on_back_to_main_menu_button_pressed() -> void:
	if _finished_selection:
		return
	_finished_selection = true
	
	Global.in_level_select_menu = false
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)

func _update_prev_next_buttons() -> void:
	if _day == 0:
		_previous_day_button.visible = false
	else:
		_previous_day_button.visible = true
	
	if _day == SaveDataManager.save_data.latest_unlocked_day:
		_next_day_button.visible = false
	else:
		_next_day_button.visible = true

func _on_previous_day_button_pressed() -> void:
	var new_day: int = _day - 1
	new_day = clampi(new_day, 0, SaveDataManager.save_data.latest_unlocked_day)
	if new_day == _day:
		return
	
	if _animating:
		return
	_animating = true
	
	_page_spread.set_right_page_view(_old_page_sub_viewport)
	
	_day = new_day
	
	_new_page_level_view.set_splash_day(_day)
	_fake_flip_page.set_right_page_view(_old_page_sub_viewport)
	_fake_flip_page.set_left_page_view(_new_page_sub_viewport)
	_page_flip_animation_player.play_backwards(_flip_to_next_animation_name)
	# Wait a moment to avoid flicker
	await get_tree().process_frame
	await get_tree().process_frame
	_page_spread.set_left_page_view(_new_page_sub_viewport)
	_fake_flip_page.visible = true
	await _page_flip_animation_player.animation_finished
	_page_spread.set_right_page_view(_new_page_sub_viewport)
	_fake_flip_page.visible = false
	
	_swap_old_and_new_vars()
	_update_prev_next_buttons()
	
	_animating = false

func _on_next_day_button_pressed() -> void:
	var new_day: int = _day + 1
	new_day = clampi(new_day, 0, SaveDataManager.save_data.latest_unlocked_day)
	if new_day == _day:
		return
	
	if _animating:
		return
	_animating = true
	
	_page_spread.set_left_page_view(_old_page_sub_viewport)
	
	_day = new_day
	
	_new_page_level_view.set_splash_day(_day)
	_fake_flip_page.set_left_page_view(_old_page_sub_viewport)
	_fake_flip_page.set_right_page_view(_new_page_sub_viewport)
	_page_flip_animation_player.play(_flip_to_next_animation_name)
	# Wait a moment to avoid flicker
	await get_tree().process_frame
	await get_tree().process_frame
	_page_spread.set_right_page_view(_new_page_sub_viewport)
	_fake_flip_page.visible = true
	await _page_flip_animation_player.animation_finished
	_page_spread.set_left_page_view(_new_page_sub_viewport)
	_fake_flip_page.visible = false
	
	_swap_old_and_new_vars()
	_update_prev_next_buttons()
	
	_animating = false

func _swap_old_and_new_vars() -> void:
	if _old_page_sub_viewport == _page_sub_viewport_a:
		_old_page_sub_viewport = _page_sub_viewport_b
		_old_page_level_view = _level_view_b
		_new_page_sub_viewport = _page_sub_viewport_a
		_new_page_level_view = _level_view_a
	else:
		_old_page_sub_viewport = _page_sub_viewport_a
		_old_page_level_view = _level_view_a
		_new_page_sub_viewport = _page_sub_viewport_b
		_new_page_level_view = _level_view_b
