class_name SaveData
extends Resource

@export var finished_or_skipped_tutorial := false

@export var latest_unlocked_day: int = 0
@export var days_bonus_objective_completed: Dictionary[int, bool] = {
	0: false,
	1: false,
	2: false,
	3: false,
	4: false,
	5: false,
}

@export var unlocked_item_ids: Array[String] = []
