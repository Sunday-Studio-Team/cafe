class_name SaveData
extends Resource

@export var finished_or_skipped_tutorial := false
@export var current_day := 0
@export var inventory: Array[Item] = []


func _init() -> void:
	reset_data()


func save_data() -> void:
	if current_day < Global.day:
		current_day = Global.day

	inventory = Global.owned_items


func load_data() -> void:
	Global.owned_items = inventory


func reset_data() -> void:
	finished_or_skipped_tutorial = false
	current_day = 0
	inventory = []
