extends Node

@warning_ignore_start("unused_signal")
# for scene switcher
signal main_scene_loaded
signal main_menu_loaded
signal game_quit
signal shift_started
signal customer_entered
# NOTE: sorry for all these weird signals that pass the customer
# i think thers probably nicer ways to do this lol
signal customer_approached_window(customer: Customer)
signal customer_started_order(customer: Customer)
signal order_completed(customer: Customer)
signal order_approved(customer: Customer)
signal customer_left_machine(customer: Customer, drink_score: int)
signal customer_timed_out_window
signal time_up
signal end_screen_finished
signal money_updated(new_value: float, old_value: float)
signal customer_score_updated(new_value: int, old_value: int)
signal alert_posted(message: String)
signal items_updated
signal finished_important_email(email_data: EmailData)
signal finished_spam_email(email_data: EmailData)
signal gui3d_exit_button_pressed
# viewmodel animation signals
signal viewmodel_animation_finished
signal hammer_animation_hit
# minigames
signal minigame_active(minigame_name: String)
signal minigame_cancelled
signal minigame_end
signal force_close_minigame
#Active Items
signal active_item_used(item: Item)
signal select_item(selection: Item)
signal active_item_menu
signal active_menu_refresh
#Animations
signal play_item_animation(animation: String)
