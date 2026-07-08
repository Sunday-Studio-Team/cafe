class_name HoldButton
extends Button

signal hold_completed

@export var time_to_hold := 5.0
@export var reset_if_let_go := false

var held := false
var held_time := 0.0


func _ready() -> void:
	button_down.connect(func(): held = true)
	button_up.connect(func(): held = false)
	mouse_exited.connect(func(): button_up.emit())


func _physics_process(delta: float) -> void:
	if held:
		held_time += delta
	elif reset_if_let_go:
		held_time = 0

	if held_time >= time_to_hold:
		hold_completed.emit()
		held_time = 0
