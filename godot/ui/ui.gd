extends CanvasLayer

enum ScoreType { MONEY, CUSTOMER }

@export var profit_label: Label
@export var profit_progress: ProgressBar
@export var customer_happiness_label: Label
@export var score_update_label: Label
@export var interactable_indicator: PanelContainer
@export var interactable_label: RichTextLabel
@export var hold_interact_progress: ProgressBar
@export var game_timer: Timer
@export var time_left_ui: Control
@export var time_left_label: Label
@export var time_left_bar: TextureProgressBar
@export var shift_starting_ending_label: RichTextLabel
@export var rules_controls: RichTextLabel
@export var money_sound: AudioStreamPlayer
@export var gain_points_sound: AudioStreamPlayer
@export var lose_points_sound: AudioStreamPlayer
@export var low_time_sound: AudioStreamPlayer
@export var cctv_indicator: TextureRect
@export var _eye_logo_red_texture: Texture2D
@export var _eye_logo_texture: Texture2D
@export var alert_ui: Control
@export var alert_label: Label
@export var shelf_item_ui: PanelContainer
@export var shelf_item_name: RichTextLabel
@export var shelf_item_description: RichTextLabel
@export var shelf_item_active_indicator: Control
@export var shelf_item_cooldown_label: RichTextLabel
@export var shelf_item_passive_indicator: Control
@export var shelf_item_sell: Button
@export var shelf_item_sold_indicator: Label
@export var day_indicator: Label
@export var rating_stars_hbox: HBoxContainer
@export var rating_label: Label
@export var customer_flow_rate_label: Label
@export var alert_sprite: AnimatedSprite2D
@export var drop_button: Button
@export var sold_item_sound: AudioStreamPlayer
@export var exit_machine_button: Button
@export var item_hover_tooltip: Control
@export var item_hover_tooltip_name: RichTextLabel
@export var item_hover_tooltip_active_indicator: Control
@export var item_hover_tooltip_cooldown_label: RichTextLabel
@export var item_hover_tooltip_passive_indicator: Control
@export var item_hover_tooltip_description: RichTextLabel
@export var stamina_bar: ProgressBar
@export var item_menu_prompt: Control
#Active Item
@export var item_ui: Control
@export var current_item_ui: Control
@export var item_indicator: PanelContainer
@export var item_text: RichTextLabel
@export var current_item_icon: TextureRect
@export var item_cooldown_bar: TextureProgressBar
@export var use_item_prompt: Button
@export var end_shift_guide: Button
@export_category("item refs")
@export var hammer: Item
@export var scrubber: Item
@export var whipped_cream: Item

var score_update_tween: Tween
var alert_tween: Tween
var time_left_warning_played := false
var star_texture_rect := TextureRect.new()
var half_star_texture_rect := TextureRect.new()
var empty_star_texture_rect := TextureRect.new()
var _employee_rating_last_update: float = -1


func _ready() -> void:
	_update_rating()

	Events.money_updated.connect(
		func(new_value: float, old_value: float):
			_on_score_updated(ScoreType.MONEY, new_value, old_value)
	)
	Events.employee_rating_updated.connect(
		func(new_value: float, old_value: float):
			_on_score_updated(ScoreType.CUSTOMER, new_value, old_value)
	)
	Events.shift_started.connect(
		func():
			shift_starting_ending_label.show()
			await get_tree().create_timer(5, false).timeout
			create_tween().tween_property(shift_starting_ending_label, "modulate", Color.TRANSPARENT, 0.5)
	)
	Events.alert_posted.connect(func(message): _on_alert_posted(message))
	Events.shift_end_sequence_started.connect(
		func():
			low_time_sound.play()
			shift_starting_ending_label.text = (
				"\n\n[wave amp=100 freq=7.5][b]SHIFT ENDING[/b][/wave]\nThe café will close after these customers leave!"
			)
			shift_starting_ending_label.modulate = Color.WHITE
			await get_tree().create_timer(6, false).timeout
			create_tween().tween_property(shift_starting_ending_label, "modulate", Color.TRANSPARENT, 0.5)
	)
	Events.time_up.connect(func(): hide())
	# TODO: figure out if this still does anything and/or should be nuked
	Events.requirements_met.connect(func(): end_shift_guide.show())

	exit_machine_button.pressed.connect(
		func():
			Events.machine_exit_button_pressed.emit()
	)

	score_update_label.modulate = Color.TRANSPARENT
	alert_ui.modulate.a = 0

	stamina_bar.max_value = Stats.current.max_stamina

	# we automatically do some stuff whenever our points change,
	# so we mute + hide that stuff
	# while we reset our points @ the start of each day lol
	var points_sound_volume := lose_points_sound.volume_db
	lose_points_sound.volume_db = -70
	score_update_label.hide()

	# we wait here to make sure some global vars like profit goal
	# get set before we show them
	await get_tree().process_frame

	if Global.day == 0:
		rules_controls.text = ""
		cctv_indicator.hide()
	if Global.day >= 1:
		rules_controls.text = ""
		cctv_indicator.hide()
	if Global.day >= 2:
		rules_controls.text += (
				"\n[b][i]rules [/i][/b]
			- no running
			- no remaking drinks"
		)
		cctv_indicator.show()

	# we make these things for the employee rating here instead of in editor
	# cos theyre dynamically added based on score
	star_texture_rect.texture = Global.star_texture
	star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	star_texture_rect.custom_minimum_size = Vector2(50, 50)
	star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	half_star_texture_rect.texture = Global.half_star_texture
	half_star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	half_star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	half_star_texture_rect.custom_minimum_size = Vector2(50, 50)
	half_star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	half_star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	empty_star_texture_rect.texture = Global.empty_star_texture
	empty_star_texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	empty_star_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	empty_star_texture_rect.custom_minimum_size = Vector2(50, 50)
	empty_star_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	empty_star_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	_update_rating()

	hide_item_ui_if_no_actives()
	Events.items_updated.connect(hide_item_ui_if_no_actives)

	# (we muted + hid these earlier, now we unmute and show)
	await get_tree().create_timer(2, false).timeout
	lose_points_sound.volume_db = points_sound_volume
	score_update_label.show()

	var hammer_t := create_tween().set_loops()
	hammer_t.tween_property(item_indicator, "modulate", Color.GOLD, 0.5)
	hammer_t.tween_property(item_indicator, "modulate", Color.ORANGE_RED, 0.5)

	var shelf_sell_t := create_tween().set_loops()
	shelf_sell_t.tween_property(shelf_item_sell, "modulate", Color.GOLD, 2)
	shelf_sell_t.tween_property(shelf_item_sell, "modulate", Color.WHITE, 2)


func _process(_delta: float) -> void:
	# looks a bit complex but basically we want to show the HUD if we're not
	# in UI (except for the machine UI where we want the tablet to show on the
	# side)

	var should_show_hud: bool = (
			not Global.in_ui
			or Global.in_machine_ui
			or Global.showing_floating_cursor and not (Global.in_pc_ui or Global.minigame_active)
	)

	# if we dont have this, the remake minigame (where we're in the machine ui)
	# wont hide the hud properly
	if Global.minigame_active:
		should_show_hud = false

	# looks cleaner if we dont show the hud behind the pause menu
	visible = should_show_hud and not get_tree().paused

	update_score_indicators()
	update_interactable_ui()
	update_time_indicator()
	update_cctv_indicator()
	# since we have a lot of time after the shift 'ends', i think we can basically
	# replace this with the ui that tells the player the shift is ending
	# (for now anyway)
	#handle_time_left_warning()
	handle_shelf_item_ui()
	update_day_indicator()
	handle_exit_machine_button_visibility()
	handle_drop_item_ui()
	handle_item_ui()
	handle_item_hover_tooltip()
	handle_stamina_bar()


func hide_item_ui_if_no_actives() -> void:
	var no_active_items_owned := true

	for item in Global.owned_items:
		if item.is_active_item:
			no_active_items_owned = false
			break

	if no_active_items_owned:
		item_ui.hide()
	else:
		item_ui.show()


func handle_stamina_bar() -> void:
	var stam: float = Global.stamina
	var max_stam: float = Stats.current.max_stamina

	stamina_bar.visible = stam < max_stam

	stamina_bar.value = stam

	if not Global.sprint_lockout_timer.is_stopped():
		stamina_bar.modulate = Color.INDIAN_RED
	else:
		stamina_bar.modulate = Color.WHITE


func handle_item_hover_tooltip() -> void:
	item_hover_tooltip.position = get_viewport().get_mouse_position()

	var hovered_icon := Global.hovered_item_icon

	if hovered_icon != null:
		var item: Item = hovered_icon.item
		item_hover_tooltip_name.text = "[b]%s Lv%s[/b]" % [item.name, item.item_level]
		item_hover_tooltip_description.text = item.description_at_levels[item.item_level]
		if item.is_active_item:
			item_hover_tooltip_passive_indicator.hide()
			item_hover_tooltip_active_indicator.show()
			item_hover_tooltip_cooldown_label.text = "(%ss cooldown)" % item.active_item_cooldown_at_levels[item.item_level]
		else:
			item_hover_tooltip_passive_indicator.show()
			item_hover_tooltip_active_indicator.hide()

	item_hover_tooltip.visible = (
			hovered_icon != null
			and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	)


func handle_exit_machine_button_visibility() -> void:
	exit_machine_button.visible = Global.in_machine_ui and not Global.minigame_active


func handle_item_ui() -> void:
	var item: Item = Global.equipped_item

	if item != null:
		current_item_ui.show()
		current_item_icon.texture = item.icon
		use_item_prompt.visible = (
				item.can_activate_anywhere
				and item.can_be_used
		)
		item_cooldown_bar.visible = not item.can_be_used
		item_cooldown_bar.value = (
			100 - item.active_item_remaining_cooldown / item.active_item_cooldown_at_levels[item.item_level] * 100
			)
	else:
		current_item_ui.hide()


func handle_drop_item_ui() -> void:
	drop_button.visible = Global.holding_ingredients and not Global.in_ui


func update_day_indicator() -> void:
	if Global.day == 0:
		day_indicator.text = ""
	else:
		match Global.day % 5: # Incase we add another week or days
			1:
				day_indicator.text = "Mon"
			2:
				day_indicator.text = "Tue"
			3:
				day_indicator.text = "Wed"
			4:
				day_indicator.text = "Thu"
			0:
				day_indicator.text = "Fri"


func handle_shelf_item_ui() -> void:
	var shelf_item: ShelfItem = Global.inspected_shelf_item

	shelf_item_ui.visible = shelf_item != null

	if not shelf_item:
		return

	if shelf_item.item.is_active_item:
		shelf_item_active_indicator.visible = true
		shelf_item_cooldown_label.text = "(%ss cooldown)" % shelf_item.item.active_item_cooldown_at_levels[shelf_item.item.item_level]
		shelf_item_passive_indicator.visible = false
	else:
		shelf_item_active_indicator.visible = false
		shelf_item_passive_indicator.visible = true

	shelf_item_name.text = "[b]%s Lv%s" % [shelf_item.item.name, shelf_item.item.item_level]
	shelf_item_description.text = shelf_item.item.description_at_levels[shelf_item.item.item_level]

	var sell_value: float = shelf_item.item.sell_value_at_levels[shelf_item.item.item_level]
	shelf_item_sell.text = "sell (%s)" % Global.float_to_price(sell_value)

	if Input.is_action_just_pressed("interact") and not shelf_item.clicked_sell:
		shelf_item.clicked_sell = true
		shelf_item_sold_indicator.text = "SOLD (%s)" % Global.float_to_price(sell_value)
		shelf_item_sold_indicator.show()
		sold_item_sound.play()
		await get_tree().create_timer(0.75, false).timeout
		shelf_item_sold_indicator.hide()
		Global.player_tips_bank += sell_value
		Global.owned_items.erase(shelf_item.item)
		shelf_item.item.unapply_stats()
		Events.items_updated.emit()


func handle_time_left_warning() -> void:
	if (
			not game_timer.is_stopped()
			and game_timer.time_left <= Stats.TIME_FOR_LOW_TIME_WARNING
			and not time_left_warning_played
	):
		var col_t := create_tween()
		col_t.tween_property(time_left_label, "modulate", Color.WHITE, 1.5).from(Color.RED)

		var size_t := create_tween()
		size_t.tween_property(time_left_label, "offset_transform_scale", Vector2.ONE * 1.1, 0.25)
		size_t.tween_property(time_left_label, "offset_transform_scale", Vector2.ONE * 1, 0.75)

		var rot_t := create_tween()
		rot_t.tween_property(time_left_label, "offset_transform_rotation", deg_to_rad(-10), 0.25)
		rot_t.tween_property(time_left_label, "offset_transform_rotation", deg_to_rad(0), 0.75)

		low_time_sound.play()
		Events.low_time_warning.emit()

		time_left_warning_played = true


func update_score_indicators() -> void:
	profit_label.text = (
			Global.float_to_price(Global.daily_cafe_money)
			+ " (goal: %s)" % Global.float_to_price(Stats.current.daily_profit_goals_each_day[Global.day])
	)
	if Global.daily_cafe_money:
		profit_progress.value = Global.daily_cafe_money / Stats.current.daily_profit_goals_each_day[Global.day] * 100

	if not Global.employee_rating == _employee_rating_last_update:
		_update_rating()


func update_time_indicator() -> void:
	time_left_ui.visible = not game_timer.is_stopped()

	var time_left := game_timer.time_left

	time_left_label.text = "⌛%s" % int(time_left)

	# 'freeze' the indicator if we paused with an item
	if game_timer.paused:
		time_left_ui.modulate = Color.SKY_BLUE
	else:
		time_left_ui.modulate = Color.WHITE

	time_left_bar.value = time_left / game_timer.wait_time * 100
	if time_left_bar.value >= 66:
		time_left_bar.modulate = Color.GREEN
	elif time_left_bar.value >= 33:
		time_left_bar.modulate = Color.ORANGE
	else:
		time_left_bar.modulate = Color.RED


func update_interactable_ui() -> void:
	var hovered_interactable: Interactable = Global.hovered_interactable

	if hovered_interactable != null:
		interactable_indicator.show()

		# show prompt to use active item if we need to

		# TODO: replace some of these unsafe refs with the item names with refs
		# to the actual items as export vars

		var equipped_item := Global.equipped_item

		if (
				hovered_interactable.name == "FixMachineButton"
				and equipped_item != null
				and equipped_item.item_id == "hammer"
				and equipped_item.can_be_used
		):
			item_indicator.show()
			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_text.text = "[%s] HAMMER 💥" % use_item_keybind
		
		elif (
				hovered_interactable.display_name == "Use machine"
				# xtremely dodgy ref to check the machine has a customer
				and hovered_interactable.get_parent().machine.customer
				and equipped_item != null
				and equipped_item.item_id == "airhorn"
				and equipped_item.can_be_used
		):
			item_indicator.show()
			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_text.text = "[%s] AIRHORN" % use_item_keybind

		elif (
				hovered_interactable.display_name.contains("camera")
				and equipped_item != null
				and equipped_item.item_id == "whipped_cream"
				and equipped_item.can_be_used
		):
			item_indicator.show()
			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_text.text = "[%s] WHIPPED CREAM" % use_item_keybind

		else:
			item_indicator.hide()
			item_text.text = ""

		if hovered_interactable.hold_to_interact:
			var interact_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().interact_action_physical_keycode)
			interactable_label.text = (
					("(HOLD) [%s] - " % interact_keybind)
					+ Global.hovered_interactable.display_name
			)

			hold_interact_progress.value = (
					hovered_interactable.time_held / hovered_interactable.time_to_hold * 100
			)

		else:
			var interact_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().interact_action_physical_keycode)
			interactable_label.text = (
					("[%s] - " % interact_keybind)
					+ Global.hovered_interactable.display_name
			)

	else:
		interactable_indicator.hide()

	hold_interact_progress.visible = (
			hovered_interactable != null
			and hovered_interactable.time_held > 0
	)


func update_cctv_indicator() -> void:
	if Global.player_in_cctv_los:
		cctv_indicator.texture = _eye_logo_red_texture
	else:
		cctv_indicator.texture = _eye_logo_texture


func _update_rating() -> void:
	var current_rating := Global.employee_rating
	_employee_rating_last_update = current_rating

	for c in rating_stars_hbox.get_children():
		c.queue_free()
	
	rating_label.text = "⭐ %s / %s" % [current_rating, Stats.current.employee_rating_max]
	customer_flow_rate_label.text = "%.1f" % Global.machine_customer_flow_rate


func _on_alert_posted(message: String) -> void:
	if alert_tween != null and alert_tween.is_running():
		alert_tween.kill()
	alert_tween = create_tween()

	alert_label.text = message
	alert_tween.tween_property(alert_ui, "modulate:a", 0, 2).from(1)

	alert_sprite.play()


# they might ultimately be better separated but i combined the funcs for the ui notis when money
# and customer scores change since they share a lot of code and use the same label for the updates
func _on_score_updated(score_type: ScoreType, new_value: float, old_value: float) -> void:
	if score_update_tween != null and score_update_tween.is_running():
		score_update_tween.kill()
	score_update_label.offset_transform_position_ratio = Vector2.ZERO
	score_update_label.offset_transform_rotation = 0
	score_update_tween = create_tween().set_parallel()

	var color: Color
	# the score label itself, not the label showing the updates like "+1$" etc
	var score_label_to_tween: Label
	score_update_label.text = ""

	var change: float = new_value - old_value
	print("change: %s" % change)
	if change > 0.0:
		match score_type:
			ScoreType.MONEY:
				color = Color.GOLD
				if is_inside_tree():
					money_sound.play()
			ScoreType.CUSTOMER:
				color = Color.GREEN
				if is_inside_tree():
					gain_points_sound.play()
	else:
		color = Color.RED
		score_update_label.text = ""
		match score_type:
			ScoreType.MONEY:
				pass
			ScoreType.CUSTOMER:
				if is_inside_tree():
					lose_points_sound.play()
	score_update_label.modulate = color

	var change_num_to_show: String = ""
	if change > 0:
		change_num_to_show = "+"

	match score_type:
		ScoreType.MONEY:
			change_num_to_show += Global.float_to_price(change)
			score_update_label.text = "%s %s" % [change_num_to_show, Global.score_update_message]
			score_label_to_tween = profit_label
		ScoreType.CUSTOMER:
			change_num_to_show += "%.1f" % change
			change_num_to_show = change_num_to_show.rstrip(".0")

			score_update_label.text = "🙂%s⭐️ %s" % [(change_num_to_show), Global.score_update_message]
			score_label_to_tween = customer_happiness_label
	create_tween().tween_property(score_label_to_tween, "modulate", Color.WHITE, 0.75).from(color)
	score_update_tween.tween_property(score_update_label, "modulate:a", 0, 1.75)
	score_update_tween.tween_property(score_update_label, "offset_transform_position_ratio:y", -2, 1.25)
	score_update_tween.tween_property(score_update_label, "offset_transform_rotation", deg_to_rad(randf_range(-10, 10)), 1.25)
