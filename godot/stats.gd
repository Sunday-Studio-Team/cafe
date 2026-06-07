extends Node
## the idea here is to refactor a lot of the game's logic so important stats
## can be easily read, edited, and updated from here

var chance_of_machine_breaking := 0.2
## chance of machine making correct drink
var machine_accuracy := 0.25
var machine_time_to_make_drink := 4.0
var customer_wait_time_machine := 20.0
var customer_wait_time_window := 30.0
var time_to_manually_make_drink := 3.0
var penalty_for_running := 4
var penalty_for_handmade_drink := 5
var daily_profit := 0.0:
	set(new_value):
		if new_value == daily_profit:
			return

		Events.money_updated.emit(new_value, daily_profit)
		daily_profit = new_value

		# we set this as empty to hopefully avoid anything weird if someone
		# accidentally updates one of these score vars without setting it
		# (like gaining money but seeing a popup like '+1 🙂' from a prev thing)
		# NOTE: i wonder if waiting a frame could ever cause anything weird if
		# we changed a score twice on successive frames D: should get reworked
		# again anyway so hopefully we wont find out .
		await get_tree().process_frame
		Global.score_update_message = ""
var daily_profit_goal := 30.0
var employee_rating := 0:
	set(new_value):
		if new_value == employee_rating:
			return

		Events.customer_score_updated.emit(new_value, employee_rating)
		employee_rating = new_value

		# (see comment for same lines in above func)
		await get_tree().process_frame
		Global.score_update_message = ""
var employee_rating_goal := 10
var ingredients_per_order := 22
var ingredients_per_bag := 50
