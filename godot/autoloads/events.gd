extends Node

@warning_ignore_start("unused_signal")
# for scene switcher
signal scene_switch_requested(game_scene: SceneSwitcher.GameScene)
signal scene_switch_in_animation_finished
signal main_scene_loaded
signal quit_game_requested
signal game_options_changed(options_data: OptionsData)
signal shift_started
signal customer_entered
# NOTE: sorry for all these weird signals that pass the customer
# i think thers probably nicer ways to do this lol
signal customer_approached_window(customer: Customer)
signal customer_started_order(customer: Customer)
signal order_completed(customer: Customer)
signal order_approved(customer: Customer)
signal order_remaking_drink
signal machine_making_drink
signal customer_left_machine(customer: Customer)
signal customer_low_time_warning
signal under_money_goal
signal time_up
signal low_time_warning
signal end_screen_finished
signal requirements_met
signal money_updated(new_value: float, old_value: float)
signal employee_rating_updated(new_value: float, old_value: float)
signal alert_posted(message: String)
signal items_updated
signal finished_important_email(email_data: EmailData)
signal finished_spam_email(email_data: EmailData)
signal ingredients_bag_consumed
signal machine_exit_button_pressed
# minigames
signal minigame_active(minigame_name: String)
signal minigame_cancelled
signal minigame_end
signal spill_clean_done
signal force_close_minigame
#Active Items
signal active_item_used(item: Item)
signal select_item(selection: Item)
signal active_item_menu
signal active_menu_refresh
# viewmodel animations
signal play_viewmodel_animation(animation_name: String)
signal viewmodel_animation_finished
# some signals that emit on certain frames of vm animations
# (to time certain stuff off)
signal bag_pickup_animation_grabbed
signal hammer_animation_hit
signal tutorial_selected
