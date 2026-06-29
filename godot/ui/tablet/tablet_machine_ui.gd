class_name TabletMachineUI
extends Control

@export var timer_ui: TextureProgressBar

var machine: Machine

@onready var timer := machine.timer


func _physics_process(_delta: float) -> void:
	if timer.is_stopped():
		timer_ui.value = 0
	else:
		timer_ui.value = (1 - timer.time_left / timer.wait_time) * 100
