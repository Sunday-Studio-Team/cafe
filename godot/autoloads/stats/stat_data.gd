# this is basically a list of a lot of stats (particularly ones we might want to change with items etc)
# - these default values are stored in base_stats.tres, and the global var Stats.current is a duplicate
# of those base stats which we can modify/fetch during gameplay for actual logic
# ----------
# setup might sound weird but i think it works pretty well cos we have all the base stats stored
# separately from the current stats so we can reset them etc AND we dont have to do anything fancy
# to add new stats other than put them in this script
class_name StatData
extends Resource

var default_move_speed := 1.2
var sprint_move_speed := 5.0
var chance_of_machine_breaking := 0.2
## chance of each score from machine
## WARNING: make sure these always sum to 1 (or actually i can probably rework
## the logic to allow them to not sum to 1, since that would be easier
## for items etc that adjust the odds)
var score_chances: Dictionary = {
	3: 0.25,
	1: 0.25,
	-1: 0.25,
	-3: 0.25,
}
var machine_time_to_make_drink := 4.0
var customer_wait_time_machine := 30.0
var customer_wait_time_window := 30.0
var time_to_manually_make_drink := 3.5
var penalty_for_running := 4
var penalty_for_handmade_drink := 5
var penalty_for_holding_ingredients := 3
var daily_profit_goal := 22.0
var employee_rating_goal := 10
var ingredients_per_order := 22
var ingredients_per_bag := 50
