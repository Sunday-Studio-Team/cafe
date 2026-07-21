class_name PauseMenu
extends CanvasLayer

signal tutorial_requested

enum State { NORMAL, CONFIRMING_RESTART, CONFIRMING_QUIT }

@export var _continue_button: Button
@export var _tutorial_button: Button
@export var restart_button: Button
@export var quit_button: Button
@export var sure_menu: PanelContainer
@export var yes_sure_button: Button
@export var no_sure_button: Button
@export var sure_info_label: Label

var state: State = State.NORMAL:
	set(new_state):
		state = new_state
		match state:
			State.CONFIRMING_RESTART:
				sure_info_label.text = "(this means going back to day 1!)"
			State.CONFIRMING_QUIT:
				sure_info_label.text = "(this means losing all progress!)"


func _ready() -> void:
	_continue_button.pressed.connect(_toggle_pause)
	_tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	quit_button.pressed.connect(func(): state = State.CONFIRMING_QUIT)
	restart_button.pressed.connect(func(): state = State.CONFIRMING_RESTART)

	yes_sure_button.pressed.connect(
		func():
			match state:
				State.CONFIRMING_QUIT:
					Events.main_menu_loaded.emit()
				State.CONFIRMING_RESTART:
					# NOTE: shouldnt this not be visible on restart anyway ? idk
					visible = false
					get_tree().paused = false
					Global.day = 1
					Events.main_scene_loaded.emit()
	)
	no_sure_button.pressed.connect(
		func():
			state = State.NORMAL
	)


func _physics_process(_delta: float) -> void:
	if (
			Input.is_action_just_pressed("pause")
			and not Global.in_ui
	):
		if state == State.NORMAL:
			_toggle_pause()
		else:
			state = State.NORMAL

	sure_menu.visible = (
			state == State.CONFIRMING_RESTART
			or state == State.CONFIRMING_QUIT
	)


func _toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	visible = !visible


func _on_tutorial_button_pressed() -> void:
	tutorial_requested.emit()
