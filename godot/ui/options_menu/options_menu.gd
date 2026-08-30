class_name OptionsMenu
extends Node

@export var _tab_container: TabContainer
# General
@export var _graphics_preset_option_view: OptionsMenuOptionView
@export var _window_mode_option_view: OptionsMenuOptionView
@export var _vsync_mode_option_view: OptionsMenuOptionView
@export var _crosshair_option_view: OptionsMenuOptionView
@export var _camera_motion_option_view: OptionsMenuOptionView
# Keybinds
@export var _move_forward_keybind_option_view: OptionsMenuKeybindOptionView
@export var _move_left_keybind_option_view: OptionsMenuKeybindOptionView
@export var _move_backward_keybind_option_view: OptionsMenuKeybindOptionView
@export var _move_right_keybind_option_view: OptionsMenuKeybindOptionView
@export var _sprint_keybind_option_view: OptionsMenuKeybindOptionView
@export var _interact_keybind_option_view: OptionsMenuKeybindOptionView
@export var _drop_item_keybind_option_view: OptionsMenuKeybindOptionView
@export var _use_contextual_active_item_keybind_option_view: OptionsMenuKeybindOptionView
@export var _pause_exit_menu_keybind_option_view: OptionsMenuKeybindOptionView
@export var _save_settings_button: Button

const _graphics_option_presets: Dictionary[String, int] = {
	"Ultra (Default)": OptionsData.GraphicsOptionsPresets.HIGH,
	"High": OptionsData.GraphicsOptionsPresets.MEDIUM,
	"Low": OptionsData.GraphicsOptionsPresets.LOW,
	"Minimum": OptionsData.GraphicsOptionsPresets.MINIMUM,
}

const _window_mode_options: Dictionary[String, int] = {
	"Windowed": OptionsData.WindowModeOption.Windowed,
	"Borderless Windowed (Default)": OptionsData.WindowModeOption.Fullscreen,
	"Exclusive Fullscreen": OptionsData.WindowModeOption.ExclusiveFullscreen,
}

const _vsync_options: Dictionary[String, int] = {
	"On (Default)": OptionsData.VsyncOption.On,
	"Off": OptionsData.VsyncOption.Off,
	"Advanced - Adaptive": OptionsData.VsyncOption.Adaptive,
	"Advanced - Mailbox": OptionsData.VsyncOption.Mailbox,
}

const _crosshair_options: Dictionary[String, int] = {
	"On (Default)": OptionsData.CrosshairOption.On,
	"Off": OptionsData.CrosshairOption.Off,
}

const _camera_motion_options: Dictionary[String, int] = {
	"Camera Effects On (Default)": OptionsData.CameraMotionOption.On,
	"Camera Effects Off (Motion Sickness Friendly)": OptionsData.CameraMotionOption.Off,
}

var _options_data: OptionsData

func _init() -> void:
	SaveDataManager.load_options_data_from_file()
	_options_data = SaveDataManager.get_options_data()

func _ready() -> void:
	Global.in_options_menu = true
	_tab_container.current_tab = 0
	_setup_option_views()
	_save_settings_button.pressed.connect(_on_save_settings_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_save_and_close_menu()
		get_viewport().set_input_as_handled()

func _setup_option_views() -> void:
	
	_graphics_preset_option_view.set_label("Graphics Preset")
	_graphics_preset_option_view.set_dropdown_options(_graphics_option_presets)
	_graphics_preset_option_view.set_selected_dropdown_option((_options_data.graphics_preset as int))
	_graphics_preset_option_view.changed_option.connect(_on_graphics_preset_option_view_changed_option)
	
	_window_mode_option_view.set_label("Window Mode")
	_window_mode_option_view.set_dropdown_options(_window_mode_options)
	_window_mode_option_view.set_selected_dropdown_option((_options_data.window_mode_option as int))
	_window_mode_option_view.changed_option.connect(_on_window_mode_option_view_changed_option)

	_vsync_mode_option_view.set_label("VSync Mode")
	_vsync_mode_option_view.set_dropdown_options(_vsync_options)
	_vsync_mode_option_view.set_selected_dropdown_option((_options_data.vsync_option as int))
	_vsync_mode_option_view.changed_option.connect(_on_vsync_mode_option_view_changed_option)

	_crosshair_option_view.set_label("Crosshair")
	_crosshair_option_view.set_dropdown_options(_crosshair_options)
	_crosshair_option_view.set_selected_dropdown_option((_options_data.crosshair_option as int))
	_crosshair_option_view.changed_option.connect(_on_crosshair_option_view_changed_option)

	_camera_motion_option_view.set_label("Motion Sickness")
	_camera_motion_option_view.set_dropdown_options(_camera_motion_options)
	_camera_motion_option_view.set_selected_dropdown_option((_options_data.camera_motion_option as int))
	_camera_motion_option_view.changed_option.connect(_on_camera_motion_option_view_changed_option)
	
	_move_forward_keybind_option_view.set_action("Move Forward", &"move_forward")
	_move_forward_keybind_option_view.set_default_keybind(_options_data.DEFAULT_MOVE_FORWARD_ACTION_PHYSICAL_KEYCODE)
	_move_forward_keybind_option_view.set_current_keybind(_options_data.move_forward_action_physical_keycode)
	_move_forward_keybind_option_view.rebound_action.connect(_on_move_forward_keybind_option_view_rebound_action)
	
	_move_left_keybind_option_view.set_action("Move Left", &"move_left")
	_move_left_keybind_option_view.set_default_keybind(_options_data.DEFAULT_MOVE_LEFT_ACTION_PHYSICAL_KEYCODE)
	_move_left_keybind_option_view.set_current_keybind(_options_data.move_left_action_physical_keycode)
	_move_left_keybind_option_view.rebound_action.connect(_on_move_left_keybind_option_view_rebound_action)
	
	_move_backward_keybind_option_view.set_action("Move Backward", &"move_backward")
	_move_backward_keybind_option_view.set_default_keybind(_options_data.DEFAULT_MOVE_BACKWARD_ACTION_PHYSICAL_KEYCODE)
	_move_backward_keybind_option_view.set_current_keybind(_options_data.move_backward_action_physical_keycode)
	_move_backward_keybind_option_view.rebound_action.connect(_on_move_backward_keybind_option_view_rebound_action)
	
	_move_right_keybind_option_view.set_action("Move Right", &"move_right")
	_move_right_keybind_option_view.set_default_keybind(_options_data.DEFAULT_MOVE_RIGHT_ACTION_PHYSICAL_KEYCODE)
	_move_right_keybind_option_view.set_current_keybind(_options_data.move_right_action_physical_keycode)
	_move_right_keybind_option_view.rebound_action.connect(_on_move_right_keybind_option_view_rebound_action)
	
	_sprint_keybind_option_view.set_action("Sprint", &"sprint")
	_sprint_keybind_option_view.set_default_keybind(_options_data.DEFAULT_SPRINT_ACTION_PHYSICAL_KEYCODE)
	_sprint_keybind_option_view.set_current_keybind(_options_data.sprint_action_physical_keycode)
	_sprint_keybind_option_view.rebound_action.connect(_on_sprint_keybind_option_view_rebound_action)
	
	_interact_keybind_option_view.set_action("Interact", &"interact")
	_interact_keybind_option_view.set_default_keybind(_options_data.DEFAULT_INTERACT_ACTION_PHYSICAL_KEYCODE)
	_interact_keybind_option_view.set_current_keybind(_options_data.interact_action_physical_keycode)
	_interact_keybind_option_view.rebound_action.connect(_on_interact_keybind_option_view_rebound_action)
	
	_drop_item_keybind_option_view.set_action("Drop Item", &"drop")
	_drop_item_keybind_option_view.set_default_keybind(_options_data.DEFAULT_DROP_ACTION_PHYSICAL_KEYCODE)
	_drop_item_keybind_option_view.set_current_keybind(_options_data.drop_action_physical_keycode)
	_drop_item_keybind_option_view.rebound_action.connect(_on_drop_keybind_option_view_rebound_action)
	
	_use_contextual_active_item_keybind_option_view.set_action("Use Contextual Active Item", &"use_item")
	_use_contextual_active_item_keybind_option_view.set_default_keybind(_options_data.DEFAULT_USE_CONTEXTUAL_ACTIVE_ITEM_ACTION_PHYSICAL_KEYCODE)
	_use_contextual_active_item_keybind_option_view.set_current_keybind(_options_data.use_contextual_active_item_action_physical_keycode)
	_use_contextual_active_item_keybind_option_view.rebound_action.connect(_on_use_contextual_active_item_keybind_option_view_rebound_action)
	
	_pause_exit_menu_keybind_option_view.set_action("Exit Menu", &"pause")
	_pause_exit_menu_keybind_option_view.set_default_keybind(_options_data.DEFAULT_PAUSE_EXIT_MENU_ACTION_PHYSICAL_KEYCODE)
	_pause_exit_menu_keybind_option_view.set_current_keybind(_options_data.pause_exit_menu_action_physical_keycode)
	_pause_exit_menu_keybind_option_view.rebound_action.connect(_on_pause_exit_menu_keybind_option_view_rebound_action)

func _on_graphics_preset_option_view_changed_option(index: int) -> void:
	_options_data.graphics_preset = (index as OptionsData.GraphicsOptionsPresets)
	_options_data.apply_options()

func _on_window_mode_option_view_changed_option(index: int) -> void:
	_options_data.window_mode_option = (index as OptionsData.WindowModeOption)
	_options_data.apply_options()

func _on_vsync_mode_option_view_changed_option(index: int) -> void:
	_options_data.vsync_option = (index as OptionsData.VsyncOption)
	_options_data.apply_options()

func _on_crosshair_option_view_changed_option(index: int) -> void:
	_options_data.crosshair_option = (index as OptionsData.CrosshairOption)
	_options_data.apply_options()

func _on_camera_motion_option_view_changed_option(index: int) -> void:
	_options_data.camera_motion_option = (index as OptionsData.CameraMotionOption)
	_options_data.apply_options()

func _on_save_settings_button_pressed() -> void:
	_save_and_close_menu()

func _on_move_forward_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.move_forward_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_move_left_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.move_left_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_move_backward_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.move_backward_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_move_right_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.move_right_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_sprint_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.sprint_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_interact_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.interact_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_drop_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.drop_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_use_contextual_active_item_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.use_contextual_active_item_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _on_pause_exit_menu_keybind_option_view_rebound_action(physical_keycode: Key) -> void:
	_options_data.pause_exit_menu_action_physical_keycode = physical_keycode
	_options_data.apply_options()

func _save_and_close_menu() -> void:
	SaveDataManager.save_options_data_to_file()
	Global.in_options_menu = false
	queue_free()
