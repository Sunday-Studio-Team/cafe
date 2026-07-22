extends Node

const TIME_FOR_LOW_TIME_WARNING := 30.0

## resource containing all base stats
@export var base: StatData

var current: StatData


func _ready() -> void:
	reset()


func reset() -> void:
	current = base.duplicate()
