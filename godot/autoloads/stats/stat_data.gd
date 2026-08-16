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
var machine_time_to_make_drink := 4.0
var customer_wait_time_machine := 35.0
var customer_wait_time_window := 25.0
var penalty_for_running := 2
var penalty_for_handmade_drink := 2
var penalty_for_holding_ingredients := 2
var penalty_for_customer_complaint := 2
var penalty_for_customer_stood_in_spill := 1
var daily_profit_goals_each_day: Dictionary[int, float] = { 1: 20.0, 2: 40.0, 3: 60.0, 4: 80.0, 5: 100.0}
var employee_rating_max := 5.0
var ingredients_per_order := 20
var ingredients_per_bag := 75
var cost_to_reroll := 5.0
var max_spills_per_shift := 2
var max_breakdowns_per_shift := 3
var clean_spill_allowed_remaining := 0.01
var extra_time_from_overtime_form_item := 25.0
var max_stamina := 125.0
# NOTE: set to 0 to effectively disable (was 25 before)
var sprint_stamina_drain_rate := 0.0
var stamina_regen_rate := 10.0
var sprint_lockout_time := 3.0
var shift_lengths_for_each_day: Dictionary[int, int] = { 1: 90, 2: 120, 3: 120, 4: 120, 5: 120 }

# Redesign stuff
# Seconds between customers entering store, linearly scaling between min and max with rating. Maybe use curves later!
var first_customer_entry_time: float = 3.0
var customer_flow_rate_at_min_rating_per_day: Dictionary[int, float] = { 1: 10.0, 2: 10.0, 3: 10.0, 4: 10.0, 5: 10.0}
var customer_flow_rate_at_max_rating_per_day: Dictionary[int, float] = { 1: 3.0, 2: 3.0, 3: 3.0, 4: 3.0, 5: 3.0}
var remade_drink_star_rating_gain_for_incorrect_main_each_day: Dictionary[int, float] = { 1: 1.0, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1 }
var remade_drink_star_rating_gain_for_incorrect_liquid_each_day: Dictionary[int, float] = { 1: 1.0, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1 }
var remade_drink_star_rating_gain_for_incorrect_extra_each_day: Dictionary[int, float] = { 1: 1.0, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1 }
