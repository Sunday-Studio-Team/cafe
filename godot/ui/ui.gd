extends CanvasLayer
class_name UI

enum ScoreType { MONEY, CUSTOMER }
enum AlertIconType { MACHINE, CUSTOMER, RULE_BREAK, RATING, MONEY}
	
# TODO: replace hardcoded file paths with @export refs
const ALERT_ICON_TYPE_IMAGE_MAP = {
	AlertIconType.MACHINE: "res://Assets/UI/alert_icons/machine_icon.png",
	AlertIconType.CUSTOMER: "res://Assets/UI/alert_icons/customer_icon.png",
	AlertIconType.RULE_BREAK: "res://Assets/UI/alert_icons/rule_break_icon.png",
	AlertIconType.RATING: "res://Assets/UI/alert_icons/rating_icon.png",
	AlertIconType.MONEY: "res://Assets/UI/alert_icons/dollar_icon.png",
}
const ALERT_DEFAULT_DURATION: float = 4.0
const ALERT_COLOR_NEUTRAL: Color = Color.WHITE
const ALERT_COLOR_RED: Color = Color.RED
const ALERT_COLOR_GREEN: Color = Color.GREEN
const ALERT_COLOR_MONEY: Color = Color.GOLD
const ALERT_QUEUE_SIZE := 5

@export var profit_label: Label
@export var profit_progress: ProgressBar
@export var customer_happiness_label: Label
@export var score_update_label: Label
@export var interactable_indicator: PanelContainer
@export var interactable_label: RichTextLabel
@export var hold_interact_progress: ProgressBar
@export var game_timer: Timer
@export var shift_starting_ending_label: RichTextLabel
@export var money_sound: AudioStreamPlayer
@export var gain_points_sound: AudioStreamPlayer
@export var lose_points_sound: AudioStreamPlayer
@export var low_time_sound: AudioStreamPlayer
@export var cctv_indicator: TextureRect
@export var _eye_logo_red_texture: Texture2D
@export var _eye_logo_texture: Texture2D
@export var alert_ui: Control
@export var day_indicator: Label
@export var rating_stars_hbox: HBoxContainer
@export var rating_label: Label
@export var customer_flow_rate_label: Label
@export var drop_button: Button
@export var exit_machine_button: Button
@export var item_hover_tooltip: Control
@export var item_hover_tooltip_name: RichTextLabel
@export var item_hover_tooltip_active_indicator: Control
@export var item_hover_tooltip_cooldown_label: RichTextLabel
@export var item_hover_tooltip_passive_indicator: Control
@export var item_hover_tooltip_description: RichTextLabel
@export var item_indicator: PanelContainer
@export var item_text: RichTextLabel
@export var end_shift_guide: Button
@export var _alert_packed_scene_uid: StringName
@export var exploding_bomb_ui: PanelContainer

var alert_queue: Array[HBoxContainer]
var score_update_tween: Tween
var time_left_warning_played := false
var _employee_rating_last_update: float = -1
var exploding_bomb_timer: float = 10.5
var exploding_bomb_on_cooldown: bool = false


func _ready() -> void:
	Events.money_updated.connect(
		func(new_value: float, old_value: float):
			play_score_update_sounds(ScoreType.MONEY, new_value, old_value)
	)
	Events.employee_rating_updated.connect(
		func(new_value: float, old_value: float):
			play_score_update_sounds(ScoreType.CUSTOMER, new_value, old_value)
	)

	Events.alert_posted.connect(
			func(message, alert_icon_type, alert_time_to_live = 4.0, color = Color.WHITE):
				_on_alert_posted(message, alert_icon_type, alert_time_to_live, color)
	)
	
	Events.shift_started.connect(
		func():
			shift_starting_ending_label.show()
			await get_tree().create_timer(5, false).timeout
			create_tween().tween_property(shift_starting_ending_label, "modulate", Color.TRANSPARENT, 0.5)
	)
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

	# we automatically do some stuff whenever our points change,
	# so we mute + hide that stuff
	# while we reset our points @ the start of each day lol
	var points_sound_volume := lose_points_sound.volume_db
	lose_points_sound.volume_linear = 0
	score_update_label.hide()

	# we wait here to make sure some global vars like profit goal
	# get set before we show them
	await get_tree().process_frame

	if Global.playing_tutorial or Global.day < 2:
		cctv_indicator.hide()
	else:
		cctv_indicator.show()

	_update_rating()

	# (we muted + hid these earlier, now we unmute and show)
	await get_tree().create_timer(2, false).timeout
	lose_points_sound.volume_db = points_sound_volume
	score_update_label.show()


func _physics_process(_delta: float) -> void:
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
	
	if not exploding_bomb_on_cooldown:
		update_exploding_bomb_ui()
	else:
		update_exploding_bomb_timer(_delta)
		
	update_cctv_indicator()
	update_day_indicator()
	handle_exit_machine_button_visibility()
	handle_drop_item_ui()
	handle_item_hover_tooltip()


func handle_item_hover_tooltip() -> void:
	item_hover_tooltip.position = get_viewport().get_mouse_position()

	var hovered_icon: TabletItemIcon = Global.hovered_item_icon

	if hovered_icon != null:
		var item: Item = hovered_icon.item
		if item.SHOW_ITEM_LEVELS:
			item_hover_tooltip_name.text = "[b]%s Lv%s[/b]" % [item.name, item.item_level]
		else:
			item_hover_tooltip_name.text = "[b]%s[/b]" % item.name
		item_hover_tooltip_description.text = item.description_at_levels[item.item_level]
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


func handle_drop_item_ui() -> void:
	drop_button.visible = Global.holding_ingredients || Global.holding_trash and not Global.in_ui


func update_day_indicator() -> void:
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


func update_score_indicators() -> void:
	profit_label.text = (
			Global.float_to_price(Global.daily_cafe_money)
			+ " (goal: %s)" % Global.float_to_price(Stats.current.daily_profit_goals_each_day[Global.day])
	)
	
	if Global.daily_cafe_money:
		profit_progress.value = Global.daily_cafe_money / Stats.current.daily_profit_goals_each_day[Global.day] * 100

	if not Global.employee_rating == _employee_rating_last_update:
		_update_rating()


func update_interactable_ui() -> void:
	var hovered_interactable: Interactable = Global.hovered_interactable

	if hovered_interactable != null:
		# show prompt to use active item if we need to
		interactable_indicator.show()

		var owned_hammer: Item = null
		var owned_air_horn: Item = null
		var owned_whipped_cream: Item = null
		var owned_air_freshener: Item = null

		for owned_item in Global.owned_items:
			if owned_item.item_id == "hammer":
				owned_hammer = owned_item
			elif owned_item.item_id == "air_horn":
				owned_air_horn = owned_item
			elif owned_item.item_id == "whipped_cream":
				owned_whipped_cream = owned_item
			elif owned_item.item_id == "air_freshener":
				owned_air_freshener = owned_item

		const USABLE_ITEM_BBCODE_OPEN: String = "[rainbow freq=0.1 sat=0.8 speed=-5.0]"
		const USABLE_ITEM_BBCODE_CLOSE: String = "[/rainbow]"
		const NON_USABLE_ITEM_BBCODE_OPEN: String = "[color=#676767]"
		const NON_USABLE_ITEM_BBCODE_CLOSE: String = "[/color]"

		if (
				hovered_interactable.interactable_id == &"fix_machine"
				and owned_hammer != null
		):
			item_indicator.show()
			var item_prompt: String = ""

			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_prompt = "[%s] HAMMER" % use_item_keybind

			if owned_hammer.can_be_used:
				item_prompt = "%s%s%s" % [USABLE_ITEM_BBCODE_OPEN, item_prompt, USABLE_ITEM_BBCODE_CLOSE]
			else:
				item_prompt = "%s%s%s" % [NON_USABLE_ITEM_BBCODE_OPEN, item_prompt, NON_USABLE_ITEM_BBCODE_CLOSE]
			item_text.text = item_prompt

		elif (
				hovered_interactable.interactable_id == &"use_machine"
				# extremely dodgy ref to check the machine has a customer
				# TODO: do this nicer
				and ((hovered_interactable.get_parent() as Machine3DGui).machine as Machine).customer
				and owned_air_horn != null
		):
			item_indicator.show()
			var item_prompt: String = ""

			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_prompt = "[%s] AIRHORN" % use_item_keybind

			if owned_air_horn.can_be_used:
				item_prompt = "%s%s%s" % [USABLE_ITEM_BBCODE_OPEN, item_prompt, USABLE_ITEM_BBCODE_CLOSE]
			else:
				item_prompt = "%s%s%s" % [NON_USABLE_ITEM_BBCODE_OPEN, item_prompt, NON_USABLE_ITEM_BBCODE_CLOSE]
			item_text.text = item_prompt

		elif (
				hovered_interactable.interactable_id == &"disarm_camera"
				and owned_whipped_cream != null
		):
			item_indicator.show()
			var item_prompt: String = ""

			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_prompt = "[%s] WHIPPED CREAM" % use_item_keybind

			if owned_whipped_cream.can_be_used:
				item_prompt = "%s%s%s" % [USABLE_ITEM_BBCODE_OPEN, item_prompt, USABLE_ITEM_BBCODE_CLOSE]
			else:
				item_prompt = "%s%s%s" % [NON_USABLE_ITEM_BBCODE_OPEN, item_prompt, NON_USABLE_ITEM_BBCODE_CLOSE]
			item_text.text = item_prompt

		elif (
				hovered_interactable.interactable_id == &"use_air_freshener"
				and owned_air_freshener != null
		):
			item_indicator.show()
			var item_prompt: String = ""

			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_prompt = "[%s] AIR FRESHENER" % use_item_keybind

			if owned_air_freshener.can_be_used:
				item_prompt = "%s%s%s" % [USABLE_ITEM_BBCODE_OPEN, item_prompt, USABLE_ITEM_BBCODE_CLOSE]
			else:
				item_prompt = "%s%s%s" % [NON_USABLE_ITEM_BBCODE_OPEN, item_prompt, NON_USABLE_ITEM_BBCODE_CLOSE]
			item_text.text = item_prompt

		elif (
				hovered_interactable.interactable_id == &"help_desk"
				and owned_air_horn != null
				and Global.customer_at_front_of_help_desk_queue != null
		):
			item_indicator.show()
			var item_prompt: String = ""

			var use_item_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().use_contextual_active_item_action_physical_keycode)
			item_prompt = "[%s] AIR HORN" % use_item_keybind

			if owned_air_horn.can_be_used:
				item_prompt = "%s%s%s" % [USABLE_ITEM_BBCODE_OPEN, item_prompt, USABLE_ITEM_BBCODE_CLOSE]
			else:
				item_prompt = "%s%s%s" % [NON_USABLE_ITEM_BBCODE_OPEN, item_prompt, NON_USABLE_ITEM_BBCODE_CLOSE]
			item_text.text = item_prompt

		else:
			item_indicator.hide()
			item_text.text = ""

		var interaction_prompt: String = ""
		if hovered_interactable.show_interact_hotkey:
			if hovered_interactable.hold_to_interact:
				var interact_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().interact_action_physical_keycode)
				interaction_prompt += "(HOLD) [%s] - " % interact_keybind

				hold_interact_progress.value = hovered_interactable.time_held / hovered_interactable.time_to_hold * 100
			else:
				var interact_keybind: String = OS.get_keycode_string(SaveDataManager.get_options_data().interact_action_physical_keycode)
				interaction_prompt += "[%s] - " % interact_keybind
		interaction_prompt += Global.hovered_interactable.display_name
		interactable_label.text = interaction_prompt

	else:
		interactable_indicator.hide()

	hold_interact_progress.visible = (
			hovered_interactable != null
			and hovered_interactable.time_held > 0
	)


func update_exploding_bomb_ui() -> void:
	var owned_exploding_bomb: Item = null

	for owned_item in Global.owned_items:
		if owned_item.item_id == "exploding_bomb":
			owned_exploding_bomb = owned_item
			
	if owned_exploding_bomb != null:
		exploding_bomb_ui.show()
		if Input.is_action_just_pressed("right_click"):
			exploding_bomb_ui.hide()
			exploding_bomb_on_cooldown = true
	else:
		exploding_bomb_ui.hide()
		
		
func update_exploding_bomb_timer(_delta: float) -> void:
	if not get_tree().paused:
		exploding_bomb_timer -= _delta
		if exploding_bomb_timer <= 0:
			exploding_bomb_timer = 10.5
			exploding_bomb_on_cooldown = false


func update_cctv_indicator() -> void:
	if Global.player_in_cctv_los:
		cctv_indicator.texture = _eye_logo_red_texture
	else:
		cctv_indicator.texture = _eye_logo_texture


func _update_rating() -> void:
	var current_rating: float = Global.employee_rating
	_employee_rating_last_update = current_rating

	for c in rating_stars_hbox.get_children():
		c.queue_free()

	rating_label.text = "⭐ %s / %s" % [current_rating, Stats.current.employee_rating_max]
	customer_flow_rate_label.text = "%.1f" % Global.machine_customer_flow_rate
	

func _get_on_alert_tween_finished(alert_to_remove: HBoxContainer):
	var _on_alert_tween_finished = func():
		# Make sure parent hasn't already been freed
		if is_instance_valid(alert_to_remove):
			# remove this alert after it is done
			alert_queue.erase(alert_to_remove)
			alert_to_remove.queue_free()
	return _on_alert_tween_finished


func _on_alert_posted(
	message: String,
	alert_icon_type: AlertIconType,
	alert_time_to_live: float = 4.0,
	color: Color = Color.WHITE
) -> void:
	if alert_queue.size() + 1 > ALERT_QUEUE_SIZE:
		# we need to remove before we start the tween to make sure that
		# any successive alerts posted don't access the same first alert
		# which can happen if a bunch of alerts are all queued at the same time
		var alert_to_remove = alert_queue.pop_at(0)

		var old_alert_tween = alert_to_remove.alert_tween
		if old_alert_tween != null and old_alert_tween.is_running():
			old_alert_tween.kill()

		var fast_fade_tween = create_tween()
		alert_to_remove.alert_tween = fast_fade_tween

		fast_fade_tween.tween_property(alert_to_remove, "modulate:a", 0, 0.25).from(1)
		# Bind is used here to ensure that the lambda doesn't throw an error if the alert is freed before
		# the lambda is called
		fast_fade_tween.finished.connect(_get_on_alert_tween_finished.bind(alert_to_remove).call())
	
	var alert_packed_scene: PackedScene = ResourceLoader.load(_alert_packed_scene_uid)
	# TODO: static typing for this
	var new_alert = alert_packed_scene.instantiate()
	new_alert.alert_label.text = message
	new_alert.icon.texture = load(ALERT_ICON_TYPE_IMAGE_MAP[alert_icon_type])

	alert_ui.add_child(new_alert)
	alert_queue.append(new_alert)

	var new_alert_tween: Tween = create_tween()
	new_alert_tween.tween_property(new_alert.alert_label, "modulate", Color.WHITE, 0.25).from(color)
	new_alert_tween.tween_property(new_alert.alert_label, "modulate", color, 0.25)
	new_alert_tween.tween_property(new_alert, "modulate:a", 1, 0.25)
	new_alert_tween.tween_interval(alert_time_to_live)
	new_alert_tween.tween_property(new_alert, "modulate:a", 0, 0.25)
	new_alert.alert_tween = new_alert_tween
	# Bind is used here to ensure that the lambda doesn't throw an error if the alert is freed before
	# the lambda is called
	new_alert_tween.finished.connect(_get_on_alert_tween_finished.bind(new_alert).call())

	new_alert.alert_sprite.play()


func play_score_update_sounds(score_type: ScoreType, new_value: float, old_value: float) -> void:
	var change: float = new_value - old_value
	if change > 0.0:
		match score_type:
			ScoreType.MONEY:
				if is_inside_tree():
					money_sound.play()
			ScoreType.CUSTOMER:
				if is_inside_tree():
					gain_points_sound.play()
	else:
		match score_type:
			ScoreType.MONEY:
				pass
			ScoreType.CUSTOMER:
				if is_inside_tree():
					lose_points_sound.play()
