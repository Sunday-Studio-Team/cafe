extends Node

@warning_ignore_start("unused_signal")
signal shift_started
signal customer_entered
# NOTE: sorry for all these weird signals that pass the customer
# i think thers probably nicer ways to do this lol
signal customer_approached_machine(customer: Customer)
signal customer_approached_window(customer: Customer)
signal customer_started_order(customer: Customer)
signal order_completed(customer: Customer)
signal order_approved(customer: Customer)
signal customer_left_machine(customer: Customer, drink_score: int)
signal time_up
signal money_updated(new_value: float, old_value: float)
signal customer_score_updated(new_value: int, old_value: int)
signal alert_posted(message: String)
# minigames
signal minigame_active
signal minigame_cancelled
signal minigame_end
