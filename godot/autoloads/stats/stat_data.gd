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
var daily_profit_goals_each_day: Dictionary[int, float] = { 1: 30.0, 2: 40.0, 3: 60.0, 4: 80.0, 5: 100.0, 0:30.0 }
var perfect_profit_goals_each_day: Dictionary[int, float] = { 1: 50.0, 2: 60.0, 3: 80.0, 4: 100.0, 5: 120.0, 0:50.0 }
var employee_rating_max := 5.0
var ingredients_per_order := 20
var ingredients_per_bag := 75
var cost_to_reroll := 5.0
var max_spills_per_shift := 2
var max_breakdowns_per_shift := 3
var clean_spill_allowed_remaining := 0.05
var extra_time_from_overtime_form_item := 25.0
var max_stamina := 125.0
# NOTE: set to 0 to effectively disable (was 25 before)
var sprint_stamina_drain_rate := 0.0
var stamina_regen_rate := 10.0
var sprint_lockout_time := 3.0
var shift_lengths_for_each_day: Dictionary[int, int] = { 1: 180, 2: 190, 3: 200, 4: 210, 5: 220, 0: 180 }

# Redesign stuff
var max_customers_queued_per_machine: int = 3
var first_customer_entry_time: float = 3.0
# Seconds between customers entering store, linearly scaling between min and max with rating. Maybe use curves later!
var customer_flow_rate_at_min_rating_per_day: Dictionary[int, float] = { 1: 12.0, 2: 12.0, 3: 12.0, 4: 12.0, 5: 12.0, 0: 12.0}
var customer_flow_rate_at_max_rating_per_day: Dictionary[int, float] = { 1: 6.0, 2: 6.0, 3: 6.0, 4: 6.0, 5: 6.0, 0: 6.0}
var remade_drink_star_rating_gain_for_incorrect_main_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var remade_drink_star_rating_gain_for_incorrect_liquid_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var remade_drink_star_rating_gain_for_incorrect_extra_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var spill_cleaned_rating_gain_each_day: Dictionary[int, float] = { 1: 1.0, 2: 0.9, 3: 0.8, 4: 0.7, 5: 0.6, 0: 1.0 }
var placated_customer_rating_gain_each_day: Dictionary[int, float] = { 1: 0.4, 2: 0.4, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.4 }
var tip_per_star_rating: float = 2.0
var camera_slow_player_speed_multiplier: float = 0.5
var camera_slow_player_duration: float = 3.0
