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
@export var end_text: RichTextLabel
@export var money_sound: AudioStreamPlayer
@export var gain_points_sound: AudioStreamPlayer
@export var lose_points_sound: AudioStreamPlayer
@export var low_time_sound: AudioStreamPlayer
@export var cctv_indicator: TextureRect
@export var alert_indicator: Label
@export var shelf_item_ui: PanelContainer
@export var shelf_item_name: RichTextLabel
@export var shelf_item_description: RichTextLabel

var score_update_tween: Tween
var alert_tween: Tween
var time_left_warning_played := false


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
	alert_indicator.modulate.a = 0

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
			"you are the new manager of a fully automated cafe!
			(flip the sign at the desk to open the shop and start your shift)

			[b]SHIFT OBJECTIVE[/b]
			make %s while keeping your employee rating (🙂) above %s"
			% [Global.float_to_price(Stats.current.daily_profit_goal), Stats.current.employee_rating_goal]
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
			they installed some security cameras to make sure you follow them!

			[b]SHIFT OBJECTIVE[/b]
			make %s while keeping your employee rating (🙂) above %s"
			% [Global.float_to_price(Stats.current.daily_profit_goal), Stats.current.employee_rating_goal]
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
			(your daily profit goal has been adjusted accordingly.)

			[b]SHIFT OBJECTIVE[/b]
			make %s while keeping your employee rating (🙂) above %s"
			% [Global.float_to_price(Stats.current.daily_profit_goal), Stats.current.employee_rating_goal]
		)
	if Global.day >= 4:
		objective.text = (
			"your boss says you're using up too many ingredients.
			new rule: don't take any more ingredients out of the store room.

			[b]SHIFT OBJECTIVE[/b]
			make %s while keeping your employee rating (🙂) above %s"
			% [Global.float_to_price(Stats.current.daily_profit_goal), Stats.current.employee_rating_goal]
		)
		rules_controls.text += "\n- no taking ingredients from store room"
	if Global.day == 5:
		objective.text = (
			"your boss has installed another machine.

			[b]SHIFT OBJECTIVE[/b]
			make %s while keeping your employee rating (🙂) above %s"
			% [Global.float_to_price(Stats.current.daily_profit_goal), Stats.current.employee_rating_goal]
		)
	if Global.day == Global.final_day:
		objective.text += "\n[color=orange](this will be your final shift!)"

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
		_on_alert_posted("⏰ time left: %ds" % Stats.TIME_FOR_LOW_TIME_WARNING)
		low_time_sound.play()
		time_left_warning_played = true


func update_score_indicators() -> void:
	profit_label.text = (
		Global.float_to_price(Global.daily_profit)
		+ " (goal: %s)" % Global.float_to_price(Stats.current.daily_profit_goal)
	)
	customer_happiness_label.text = "🙂" + str(Global.employee_rating) + " (goal: %s)" % Stats.current.employee_rating_goal


func update_time_indicator() -> void:
	time_left_label.visible = not game_timer.is_stopped()
	time_left_label.text = "TIME LEFT IN SHIFT: %ss" % int(game_timer.time_left)


func update_interactable_ui() -> void:
	var hovered_interactable: Interactable = Global.hovered_interactable

	if hovered_interactable != null:
		interactable_indicator.show()
			
		if hovered_interactable.name == "FixMachineButton" and Global.has_item("Hammer"):
			interactable_label.text = (
				"(HOLD) [E] - "
				+ Global.hovered_interactable.display_name
				+
					" [Q] Hammer"
			)

		elif hovered_interactable.hold_to_interact:
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

	alert_indicator.text = message
	alert_tween.tween_property(alert_indicator, "modulate:a", 0, 2).from(1)


# they might ultimately be better separated but i combined the funcs for the ui notis when money
# and customer scores change since they share a lot of code and use the same label for the updates
func _on_score_updated(score_type: ScoreType, new_value: float, old_value: float) -> void:
	if score_update_tween != null and score_update_tween.is_running():
		score_update_tween.kill()
	score_update_tween = create_tween()

	var color: Color
	# the score label itself, not the label showing the updates like "+1$" etc
	var score_label_to_tween: Label

	var change := new_value - old_value
	if change > 0:
		score_update_label.text = "+"
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
		score_update_label.text = "-"
		match score_type:
			ScoreType.MONEY:
				pass
			ScoreType.CUSTOMER:
				if is_inside_tree():
					lose_points_sound.play()

	score_update_label.modulate = color
	match score_type:
		ScoreType.MONEY:
			score_update_label.text += "$"
			score_label_to_tween = profit_label
		ScoreType.CUSTOMER:
			score_update_label.text += "🙂"
			score_label_to_tween = customer_happiness_label
	create_tween().tween_property(score_label_to_tween, "modulate", Color.WHITE, 0.75).from(color)
	score_update_label.text += "%s %s" % [abs(int(change)), Global.score_update_message]
	score_update_tween.tween_property(score_update_label, "modulate:a", 0, 2)
