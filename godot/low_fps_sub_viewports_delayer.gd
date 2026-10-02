class_name LowFpsSubViewportsDelayer
extends Node

func _init() -> void:
	Global.low_fps_updaters.clear()

func _ready() -> void:
	var i: int = 0
	const i_increment: int = 16
	for low_fps_updater in Global.low_fps_updaters:
		low_fps_updater.set_delay(i)
		i += i_increment
