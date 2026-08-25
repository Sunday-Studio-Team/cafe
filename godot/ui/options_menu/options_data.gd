class_name OptionsData
extends Resource

const LATEST_OPTIONS_VERSION: int = 1
## 0: Initial with only Graphics, Crosshair, and CameraMotion.
## 1: Added keybinds.
@export var options_version: int = 0

enum GraphicsOptionsPresets {
	HIGH,
	MEDIUM,
	LOW,
	MINIMUM,
}

@export var graphics_preset: GraphicsOptionsPresets = GraphicsOptionsPresets.HIGH

enum CrosshairOption {
	On,
	Off,
}
	
@export var crosshair_option: CrosshairOption = CrosshairOption.On

enum CameraMotionOption {
	On,
	Off,
}
	
@export var camera_motion_option: CameraMotionOption = CameraMotionOption.On

const DEFAULT_MOVE_FORWARD_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_W
@export var move_forward_action_physical_keycode: Key = DEFAULT_MOVE_FORWARD_ACTION_PHYSICAL_KEYCODE

const DEFAULT_MOVE_LEFT_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_A
@export var move_left_action_physical_keycode: Key = DEFAULT_MOVE_LEFT_ACTION_PHYSICAL_KEYCODE

const DEFAULT_MOVE_BACKWARD_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_S
@export var move_backward_action_physical_keycode: Key = DEFAULT_MOVE_BACKWARD_ACTION_PHYSICAL_KEYCODE

const DEFAULT_MOVE_RIGHT_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_D
@export var move_right_action_physical_keycode: Key = DEFAULT_MOVE_RIGHT_ACTION_PHYSICAL_KEYCODE

const DEFAULT_SPRINT_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_SHIFT
@export var sprint_action_physical_keycode: Key = DEFAULT_SPRINT_ACTION_PHYSICAL_KEYCODE

const DEFAULT_INTERACT_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_E
@export var interact_action_physical_keycode: Key = DEFAULT_INTERACT_ACTION_PHYSICAL_KEYCODE

const DEFAULT_DROP_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_F
@export var drop_action_physical_keycode: Key = DEFAULT_DROP_ACTION_PHYSICAL_KEYCODE

const DEFAULT_USE_CONTEXTUAL_ACTIVE_ITEM_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_Q
@export var use_contextual_active_item_action_physical_keycode: Key = DEFAULT_USE_CONTEXTUAL_ACTIVE_ITEM_ACTION_PHYSICAL_KEYCODE

const DEFAULT_PAUSE_EXIT_MENU_ACTION_PHYSICAL_KEYCODE: Key = Key.KEY_ESCAPE
@export var pause_exit_menu_action_physical_keycode: Key = DEFAULT_PAUSE_EXIT_MENU_ACTION_PHYSICAL_KEYCODE

func _init() -> void:
	_reset_all_keybinds()

func apply_options() -> void:	
	Events.game_options_changed.emit(self)
	
	_set_action_first_key_input_event(&"move_forward", move_forward_action_physical_keycode)
	_set_action_first_key_input_event(&"move_left", move_left_action_physical_keycode)
	_set_action_first_key_input_event(&"move_back", move_backward_action_physical_keycode)
	_set_action_first_key_input_event(&"move_right", move_right_action_physical_keycode)
	_set_action_first_key_input_event(&"sprint", sprint_action_physical_keycode)
	_set_action_first_key_input_event(&"interact", interact_action_physical_keycode)
	_set_action_first_key_input_event(&"drop", drop_action_physical_keycode)
	_set_action_first_key_input_event(&"use_item", use_contextual_active_item_action_physical_keycode)
	_set_action_first_key_input_event(&"pause", pause_exit_menu_action_physical_keycode)

func update_version() -> void:
	if options_version == LATEST_OPTIONS_VERSION:
		return
	
	if options_version == 0 and LATEST_OPTIONS_VERSION >= 1:
		_reset_all_keybinds()
		print("Upgraded options version from 0 to 1+")
	
	options_version = LATEST_OPTIONS_VERSION

func _reset_all_keybinds() -> void:
	# Get them from Project Settings.
	interact_action_physical_keycode = _get_action_first_key_input_event(&"interact").physical_keycode

func _get_action_first_key_input_event(action_name: StringName) -> InputEventKey:
	var input_events: Array[InputEvent] = InputMap.action_get_events(action_name)
	for input_event in input_events:
		if input_event is InputEventKey:
			var input_event_key: InputEventKey = input_event as InputEventKey
			return input_event_key
	return null

func _set_action_first_key_input_event(action_name: StringName, keycode: Key) -> void:
	var input_event_key: InputEventKey = _get_action_first_key_input_event(action_name)
	input_event_key.physical_keycode = keycode
