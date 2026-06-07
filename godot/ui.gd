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
@export var end_text: RichTextLabel
@export var money_sound: AudioStreamPlayer
@export var gain_points_sound: AudioStreamPlayer
@export var lose_points_sound: AudioStreamPlayer
@export var cctv_indicator: TextureRect
@export var alert_indicator: Label

var score_update_tween: Tween
var alert_tween: Tween


func _ready() -> void:
	Events.time_up.connect(_on_time_up)
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

	score_update_label.modulate = Color.TRANSPARENT
	alert_indicator.modulate.a = 0

	objective.text = (
		"you are the new manager of a fully automated cafe!
		(flip the sign at the desk to open the shop and start your shift)

		[b]SHIFT OBJECTIVE[/b]
		make %s while keeping your employee rating (🙂) above %s

		p.s. your boss is watching on the security cameras, so follow the [b][i]rules[/i][/b]."
		% [Global.float_to_price(Stats.daily_profit_goal), Stats.employee_rating_goal]
	)


func _physics_process(_delta: float) -> void:
	update_score_indicators()
	update_interactable_ui()
	update_time_indicator()
	update_cctv_indicator()


func update_score_indicators() -> void:
	profit_label.text = (
		Global.float_to_price(Stats.daily_profit)
		+ " (goal: %s)" % Global.float_to_price(Stats.daily_profit_goal)
	)
	customer_happiness_label.text = "🙂 " + str(Stats.employee_rating) + " (goal: %s)" % Stats.employee_rating_goal


func update_time_indicator() -> void:
	time_left_label.visible = not game_timer.is_stopped()
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


# TODO: rework this into a generic alert thing that can show when machine broke too
func _on_alert_posted(message: String) -> void:
	if alert_tween != null and alert_tween.is_running():
		alert_tween.kill()
	alert_tween = create_tween()

	alert_indicator.text = message
	alert_tween.tween_property(alert_indicator, ^"modulate:a", 0, 2).from(1)


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
				money_sound.play()
			ScoreType.CUSTOMER:
				color = Color.GREEN
				gain_points_sound.play()
	else:
		color = Color.RED
		score_update_label.text = "-"
		match score_type:
			ScoreType.MONEY:
				pass
			ScoreType.CUSTOMER:
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


func _on_time_up() -> void:
	if (
		Stats.employee_rating >= Stats.employee_rating_goal
		and Stats.daily_profit >= Stats.daily_profit_goal
	):
		end_text.text = "[color=green][b]you win !"
	else:
		end_text.text = "[color=red][b]you lose !"
