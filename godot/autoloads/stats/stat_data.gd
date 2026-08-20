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
var chance_of_machine_breaking_at_shift_start_each_day: Dictionary[int, float] = { 1: 0.08, 2: 0.07, 3: 0.06, 4: 0.05, 5: 0.04, 0: 0.0 }
var chance_of_machine_breaking_at_shift_end_each_day: Dictionary[int, float] = { 1: 0.3, 2: 0.31, 3: 0.32, 4: 0.33, 5: 0.33, 0: 0.0 }
var machine_chance_of_spill: float = 0.05
var chance_of_machine_spill_at_shift_start_each_day: Dictionary[int, float] = { 1: 0.1, 2: 0.09, 3: 0.08, 4: 0.07, 5: 0.06, 0: 0.0 }
var chance_of_machine_spill_at_shift_end_each_day: Dictionary[int, float] = { 1: 0.3, 2: 0.31, 3: 0.32, 4: 0.33, 5: 0.34, 0: 0.0 }
var machine_time_to_make_drink := 4.0
var customer_wait_time_machine := 35.0
var customer_wait_time_help_desk := 25.0
var daily_profit_goals_each_day: Dictionary[int, float] = { 1: 30.0, 2: 35.0, 3: 40.0, 4: 50.0, 5: 60.0, 0: 100.0 }
var perfect_profit_goals_each_day: Dictionary[int, float] = { 1: 40.0, 2: 50.0, 3: 60.0, 4: 80.0, 5: 100.0, 0: 100.0 }
var employee_rating_max := 5.0
var machine_starting_ingredients: int = 50
var machine_max_ingredients: int = 100
var ingredients_per_order: int = 10
var ingredients_per_bag: int = 50
var cost_to_reroll := 5.0
var max_spills_per_shift := 2
var max_breakdowns_per_shift := 3
var clean_spill_allowed_remaining := 0.05
var max_stamina := 125.0
# NOTE: set to 0 to effectively disable (was 25 before)
var sprint_stamina_drain_rate := 0.0
var stamina_regen_rate := 10.0
var sprint_lockout_time := 3.0
var shift_lengths_for_each_day: Dictionary[int, int] = { 1: 180, 2: 190, 3: 200, 4: 220, 5: 240, 0: 999 }

# Redesign stuff
var max_customers_queued_per_machine: int = 3
var max_customers_queued_help_desk: int = 3
var first_machine_customer_entry_time: float = 3.0
var first_help_desk_customer_entry_time: float = 8.0
# Seconds between customers entering store, linearly scaling between min and max with rating. Maybe use curves later!
var machine_customer_flow_rate_at_min_rating_per_day: Dictionary[int, float] = { 1: 12.0, 2: 12.0, 3: 12.0, 4: 12.0, 5: 12.0, 0: 12.0}
var machine_customer_flow_rate_at_max_rating_per_day: Dictionary[int, float] = { 1: 6.0, 2: 6.0, 3: 6.0, 4: 6.0, 5: 6.0, 0: 6.0}
var help_desk_customer_flow_rate_at_min_rating_per_day: Dictionary[int, float] = { 1: 20.0, 2: 20.0, 3: 20.0, 4: 20.0, 5: 20.0, 0: 999.0}
var help_desk_customer_flow_rate_at_max_rating_per_day: Dictionary[int, float] = { 1: 15.0, 2: 15.0, 3: 15.0, 4: 15.0, 15: 15.0, 0: 999.0}
var remade_drink_star_rating_gain_for_incorrect_main_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var remade_drink_star_rating_gain_for_incorrect_liquid_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var remade_drink_star_rating_gain_for_incorrect_extra_each_day: Dictionary[int, float] = { 1: 0.6, 2: 0.5, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.1  }
var accept_incorrect_drink_star_rating_multiplier: float = 0.2
var accept_incorrect_drink_star_rating_rounding: float = 0.1
var customer_steps_on_spill_rating_loss_each_day: Dictionary[int, float] = { 1: 0.2, 2: 0.25, 3: 0.3, 4: 0.35, 5: 0.4, 0: 0.2 }
var spill_cleaned_rating_gain_each_day: Dictionary[int, float] = { 1: 1.0, 2: 0.9, 3: 0.8, 4: 0.7, 5: 0.6, 0: 1.0 }
var help_desk_customer_success_rating_gain_each_day: Dictionary[int, float] = { 1: 0.4, 2: 0.35, 3: 0.3, 4: 0.2, 5: 0.1, 0: 0.4 }
var help_desk_customer_timed_out_rating_loss_each_day: Dictionary[int, float] = { 1: 0.2, 2: 0.25, 3: 0.3, 4: 0.35, 5: 0.4, 0: 0.4 }
var tip_per_star_rating: float = 3.0
var camera_slow_player_speed_multiplier: float = 0.5
var camera_slow_player_duration: float = 3.0
