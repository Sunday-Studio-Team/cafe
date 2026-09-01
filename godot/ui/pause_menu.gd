class_name PauseMenu
extends CanvasLayer

signal tutorial_requested

enum State { NORMAL, IN_OPTIONS, CONFIRMING_RESTART, CONFIRMING_QUIT }

@export var _continue_button: Button
@export var _tutorial_button: Button
@export var _options_button: Button
@export var _options_menu_packed_scene: PackedScene
@export var restart_button: Button
@export var quit_button: Button
@export var sure_menu: Control
# this is separate from the menu which also includes a background
@export var sure_panel: PanelContainer
@export var yes_sure_button: Button
@export var no_sure_button: Button
@export var sure_info_label: Label

var buttons: Array[Button]
var state: State = State.NORMAL:
	set(new_state):
		state = new_state
		match state:
			State.CONFIRMING_RESTART:
				if SaveDataManager.save_data.finished_or_skipped_tutorial:
					sure_info_label.text = "(this means going back to day 1!)"
				else:
					sure_info_label.text = "(this means losing all progress!)"
			State.CONFIRMING_QUIT:
				sure_info_label.text = "(this means losing all progress!)"


func _ready() -> void:
	_continue_button.pressed.connect(_toggle_pause)
	_tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(func(): state = State.CONFIRMING_QUIT)
	restart_button.pressed.connect(func(): state = State.CONFIRMING_RESTART)
	sure_panel.visibility_changed.connect(
		func():
			if sure_panel.visible:
				create_tween().tween_property(
					sure_panel,
					"offset_transform_scale",
					Vector2.ONE,
					0.1,
				).from(Vector2.ZERO)
	)
	yes_sure_button.pressed.connect(
		func():
			match state:
				State.CONFIRMING_QUIT:
					Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_MENU)
				State.CONFIRMING_RESTART:
					# NOTE: shouldnt this not be visible on restart anyway ? idk
					visible = false
					get_tree().paused = false
					if SaveDataManager.save_data.finished_or_skipped_tutorial:
						Global.day = 1
					Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
	)
	no_sure_button.pressed.connect(not_sure)

	setup_button_tweens()

func _unhandled_input(input_event: InputEvent) -> void:
	if (
			input_event.is_action_pressed("pause")
			and not Global.in_ui
	):
		if state == State.IN_OPTIONS:
			# the options menu itself handles hiding, we just make eat the input
			# and set the state here
			state = State.NORMAL
		elif state == State.NORMAL:
			_toggle_pause()
		else:
			not_sure()


func _process(_delta: float) -> void:
	sure_menu.visible = (
			state == State.CONFIRMING_RESTART
			or state == State.CONFIRMING_QUIT
	)


func not_sure() -> void:
	var t := create_tween().tween_property(
		sure_panel,
		"offset_transform_scale",
		Vector2.ZERO,
		0.1,
	)
	await t.finished
	state = State.NORMAL


func setup_button_tweens() -> void:
	for button: Button in find_children("*", "Button"):
		button.offset_transform_enabled = true

		const T_DUR := 0.1

		button.mouse_entered.connect(
			func():
				var t := create_tween().set_parallel()
				t.tween_property(button, "offset_transform_scale", Vector2.ONE * 1.1, T_DUR)
				t.tween_property(button, "offset_transform_rotation", deg_to_rad(randf_range(-10, 10)), T_DUR)
		)

		button.mouse_exited.connect(
			func():
				var t := create_tween().set_parallel()
				t.tween_property(button, "offset_transform_scale", Vector2.ONE, T_DUR)
				t.tween_property(button, "offset_transform_rotation", 0, T_DUR)
		)


func _toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	visible = !visible


func _on_tutorial_button_pressed() -> void:
	tutorial_requested.emit()


func _on_options_button_pressed() -> void:
	state = State.IN_OPTIONS
	var options_menu: OptionsMenu = _options_menu_packed_scene.instantiate()
	add_sibling(options_menu, true)
