extends CanvasLayer

enum ScoreType { MONEY, CUSTOMER }

@export var profit_label: Label
@export var customer_happiness_label: Label
@export var score_update_label: Label
@export var interactable_indicator: PanelContainer
@export var interactable_label: RichTextLabel
@export var hold_interact_progress: ProgressBar
@export var game_timer: Timer
@export var time_left_label: Label
@export var objective: RichTextLabel
@export var rules_controls: RichTextLabel
@export var money_sound: AudioStreamPlayer
@export var gain_points_sound: AudioStreamPlayer
@export var lose_points_sound: AudioStreamPlayer
@export var low_time_sound: AudioStreamPlayer
@export var low_time_warning_label: Label
@export var cctv_indicator: TextureRect
@export var alert_ui: Control
@export var alert_label: Label
@export var shelf_item_ui: PanelContainer
@export var shelf_item_name: RichTextLabel
@export var shelf_item_description: RichTextLabel
@export var day_indicator: Label
@export var rating_stars_hbox: HBoxContainer
@export var rating_goal_label: Label
@export var alert_sprite: AnimatedSprite2D
@export var drop_button: Button

var score_update_tween: Tween
var alert_tween: Tween
var time_left_warning_played := false
var star_texture_rect := TextureRect.new()
var half_star_texture_rect := TextureRect.new()
var empty_star_texture_rect := TextureRect.new()


func _ready() -> void:
	Events.money_updated.connect(
		func(new_value: float, old_value: float):
			_on_score_updated(ScoreType.MONEY, new_value, old_value)
	)
	Events.customer_score_updated.connect(
		func(new_value: int, old_value: int):
			_on_score_updated(ScoreType.CUSTOMER, new_value, old_value)
	)
	Events.shift_started.connect(
		func():
			objective.text = "[b]SHIFT STARTING"
			await get_tree().create_timer(5, false).timeout
			objective.hide()
	)
	Events.alert_posted.connect(func(message): _on_alert_posted(message))
	Events.time_up.connect(func(): hide())

	score_update_label.modulate = Color.TRANSPARENT
	alert_ui.modulate.a = 0

	# we automatically play a sound whenever our points change,
	# so we mute that sound while we reset our points @ the start of each day
	# lol
	var points_sound_volume := lose_points_sound.volume_db
	lose_points_sound.volume_db = -70

	# we wait here to make sure some global vars like profit goal
	# get set before we show them
	await get_tree().process_frame
	if Global.day >= 1:
		objective.text = (
				"You are the new manager of a fully automated cafe!
This is your first trial shift - make it through the week to keep your new position!
(check your emails on the computer for more details)"
		)
		rules_controls.text = (
				"[b][i]controls [/i][/b]
			[b]WASD[/b] move
			[b]E[/b] interact
			[b]Shift[/b] sprint"
		)
		cctv_indicator.hide()
	if Global.day >= 2:
		objective.text = (
				"your boss has instated some new store [i]rules[/i].
they installed some security cameras to make sure you follow them!"
		)
		rules_controls.text += (
				"\n[b][i]rules [/i][/b]
			- no running
			- no handmade drinks"
		)
		cctv_indicator.show()
	if Global.day >= 3:
		objective.text = (
				"your boss has installed another machine! it's located around the corner on the left.
(your daily profit goal has been adjusted accordingly.)"
		)
	if Global.day >= 4:
		objective.text = (
				"your boss says you're using up too many ingredients.
new rule: don't take any more ingredients out of the store room."
		)
		rules_controls.text += "\n- no taking ingredients from store room"
	if Global.day == 5:
		objective.text = (
				"your boss has installed another machine."
		)
	@warning_ignore("integer_division")
	objective.text += (
			"\n\n[b]SHIFT OBJECTIVE[/b]
make %s while keeping your employee rating (🙂) above %s⭐️"
			% [Global.float_to_price(Stats.current.daily_profit_goal), (Stats.current.employee_rating_goal / 2)]
	)
	if Global.day == Global.final_day:
		objective.text += "\n[color=orange](this will be your final shift!)"

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

	# (we muted this earlier, now we unmute)
	await get_tree().create_timer(2, false).timeout
	lose_points_sound.volume_db = points_sound_volume


func _physics_process(_delta: float) -> void:
	update_score_indicators()
	update_interactable_ui()
	update_time_indicator()
	update_cctv_indicator()
	handle_time_left_warning()
	handle_shelf_item_ui()
	update_day_indicator()
	handle_drop_item_ui()


func handle_drop_item_ui():
	drop_button.visible = Global.holding_ingredients and not Global.in_ui


func update_day_indicator() -> void:
	day_indicator.text = "DAY %s/%s" % [Global.day, Global.final_day]


func handle_shelf_item_ui() -> void:
	var shelf_item: ShelfItem = Global.inspected_shelf_item

	shelf_item_ui.visible = shelf_item != null

	if not shelf_item:
		return

	shelf_item_name.text = "[b]%s" % shelf_item.item.name
	shelf_item_description.text = shelf_item.item.description


func handle_time_left_warning() -> void:
	if (
			not game_timer.is_stopped()
			and game_timer.time_left <= Stats.TIME_FOR_LOW_TIME_WARNING
			and not time_left_warning_played
	):
		low_time_warning_label.text = "‼️⏰ %ds left" % Stats.TIME_FOR_LOW_TIME_WARNING
		low_time_sound.play()
		low_time_warning_label.show()
		time_left_warning_played = true
		var t := create_tween()
		t.tween_property(low_time_warning_label, "offset_transform_scale", Vector2(4, 4), 0.75)
		t.tween_property(low_time_warning_label, "offset_transform_scale", Vector2(1, 1), 0.5)
		t.tween_property(low_time_warning_label, "modulate:a", 0, 2)
		await t.finished
		low_time_warning_label.hide()


func update_score_indicators() -> void:
	profit_label.text = (
			Global.float_to_price(Global.daily_profit)
			+ " (goal: %s)" % Global.float_to_price(Stats.current.daily_profit_goal)
	)

	for c in rating_stars_hbox.get_children():
		c.queue_free()

	var current_rating := Global.employee_rating
	var rating_is_even := current_rating % 2 == 0
	var rating_shown := 0

	if rating_is_even:
		for i in current_rating / 2.0:
			rating_stars_hbox.add_child(star_texture_rect.duplicate())
			rating_shown += 1
	else:
		for i in (current_rating - 1) / 2.0:
			rating_stars_hbox.add_child(star_texture_rect.duplicate())
			rating_shown += 1
		rating_stars_hbox.add_child(half_star_texture_rect.duplicate())
		rating_shown += 1

	for i in 5 - rating_shown:
		rating_stars_hbox.add_child(empty_star_texture_rect.duplicate())

	rating_goal_label.text = "(goal: %s⭐️)" % (int(Stats.current.employee_rating_goal / 2.0))


func update_time_indicator() -> void:
	if game_timer.is_stopped():
		time_left_label.text = "SHIFT LENGTH: %ss" % int(game_timer.wait_time)
	else:
		time_left_label.text = "TIME LEFT IN SHIFT: %ss" % int(game_timer.time_left)


func update_interactable_ui() -> void:
	var hovered_interactable: Interactable = Global.hovered_interactable

	if hovered_interactable != null:
		interactable_indicator.show()

		if hovered_interactable.hold_to_interact:
			interactable_label.text = (
					"(HOLD) [E] - "
					+ Global.hovered_interactable.display_name
			)

			hold_interact_progress.value = (
					hovered_interactable.time_held / hovered_interactable.time_to_hold * 100
			)

		else:
			interactable_label.text = (
					"[E] - "
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
		cctv_indicator.modulate = Color.RED
	else:
		cctv_indicator.modulate = Color.WHITE


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

	var change := new_value - old_value
	if change > 0:
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
			change /= 2
			change_num_to_show += "%.1f" % change
			change_num_to_show = change_num_to_show.rstrip(".0")

			score_update_label.text = "🙂%s⭐️ %s" % [(change_num_to_show), Global.score_update_message]
			score_label_to_tween = customer_happiness_label
	create_tween().tween_property(score_label_to_tween, "modulate", Color.WHITE, 0.75).from(color)
	score_update_tween.tween_property(score_update_label, "modulate:a", 0, 1.75)
	score_update_tween.tween_property(score_update_label, "offset_transform_position_ratio:y", -2, 1.25)
	score_update_tween.tween_property(score_update_label, "offset_transform_rotation", deg_to_rad(randf_range(-10, 10)), 1.25)
