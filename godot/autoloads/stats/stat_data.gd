# this is basically a list of a lot of stats (particularly ones we might want to change with items etc)
# - these default values are stored in base_stats.tres, and the global var Stats.current is a duplicate
# of those base stats which we can modify/fetch during gameplay for actual logic
# ----------
# setup might sound weird but i think it works pretty well cos we have all the base stats stored
# separately from the current stats so we can reset them etc AND we dont have to do anything fancy
# to add new stats other than put them in this script
class_name StatData
extends Resource

var default_move_speed := 2.0
var sprint_move_speed := 5.0
var player_accel := 25.0
var player_decel := 25.0
var chance_of_machine_breaking := 0.15
var machine_chance_of_spill := 0.2
## chance of each score from machine
## WARNING: make sure these always sum to 1 (or actually i can probably rework
## the logic to allow them to not sum to 1, since that would be easier
## for items etc that adjust the odds)
var score_chances_3 := 0.25
var score_chances_1 := 0.25
var score_chances_neg1 := 0.25
var score_chances_neg3 := 0.25
var score_chances: Dictionary = {
	3: score_chances_3,
	1: score_chances_1,
	-1: score_chances_neg1,
	-3: score_chances_neg3,
}
var machine_time_to_make_drink := 4.0
var customer_wait_time_machine := 35.0
var customer_wait_time_window := 25.0
var penalty_for_running := 2
var penalty_for_handmade_drink := 2
var penalty_for_holding_ingredients := 2
var penalty_for_customer_complaint := 2
var penalty_for_customer_stood_in_spill := 1
var daily_profit_goal := 22.0
var employee_rating_goal := 6
var ingredients_per_order := 20
var ingredients_per_bag := 50
var customer_spawn_interval := 5.0
var cost_to_reroll := 5.0
var max_spills_per_shift := 2
var max_breakdowns_per_shift := 3
var clean_spill_allowed_remaining := 0.01
var extra_time_from_overtime_form_item := 25.0
var max_stamina := 125.0
var sprint_stamina_drain_rate := 25.0
var stamina_regen_rate := 10.0
var sprint_lockout_time := 3.0
