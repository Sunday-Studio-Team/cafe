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
signal order_remade(customer: Customer)
signal order_accepted(customer: Customer)
signal order_served(customer: Customer)
signal order_remaking_drink
signal machine_making_drink
signal customer_left_machine(customer: Customer)
signal customer_leave
signal customer_low_time_warning
signal under_money_goal
signal shift_end_sequence_started
signal time_up
signal low_time_warning
signal end_screen_finished
signal requirements_met
signal money_updated(new_value: float, old_value: float)
signal employee_rating_updated(new_value: float, old_value: float)
signal alert_posted(
	message: String,
	alert_icon_type: UI.AlertIconType,
	alert_time_to_live: float,
	color: Color,
)
signal items_updated
signal finished_important_email(email_data: EmailData)
signal finished_spam_email(email_data: EmailData)
signal ingredients_bag_consumed
signal machine_exit_button_pressed
signal player_left_office
signal tippy_boss_kidnapped_player
signal tippy_boss_released_player
signal spawn_specific_customer(name: String, help_desk: String)
signal air_freshener_used(customer_wait_duration_extension: float)
# minigames
# TODO: combine some of these or something
# (below are my BEST GUESSES at what each currently do) - jack
# starts the given minigame (name mapped to game in minigame_controller.gd)
signal minigame_active(minigame_name: String)
# doesnt trigger anything, but is emitted after force closing to tell other objects
# (could probably replace this + force close with just a `cancelled` argument in minigame_end ? ? ?)
signal minigame_cancelled
# closes the current minigame
signal minigame_end
signal spill_clean_done
# closes the minigame
signal force_close_minigame
# Active Items
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
signal trash_pickup_animation_grabbed
signal hammer_animation_hit
signal air_horn_animation_just_blasted
signal whipped_cream_animation_shot

signal tutorial_selected
# Free Cam
signal free_cam_toggled
signal free_cam_set_speed(speed: float)
# PC Cursor
signal pc_state_change(using_pc: bool)
