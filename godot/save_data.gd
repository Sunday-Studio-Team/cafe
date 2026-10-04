class_name SaveData
extends Resource

@export var latest_tutorial_completed_day: int = 0

## This is set to 6 after finishing day 5
@export var latest_unlocked_day: int = 1
@export var days_bonus_objective_completed: Dictionary[int, bool] = {
	1: false,
	2: false,
	3: false,
	4: false,
	5: false,
}
