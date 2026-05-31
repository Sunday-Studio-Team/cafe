extends Node

@warning_ignore_start("unused_signal")
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
signal gained_money
signal customer_score_updated(increased: bool)
signal player_caught_sprinting
signal player_caught_remaking
#Minigame Events
signal minigame_active
signal minigame_end
