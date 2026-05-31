extends CanvasLayer

@export var profit_label: Label
@export var customer_happiness_label: Label
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
@export var caught_printing_label: Label
@export var caught_remaking_label: Label


func _ready() -> void:
	Events.time_up.connect(_on_time_up)
	Events.gained_money.connect(
		func():
			create_tween().tween_property(profit_label, "modulate", Color.WHITE, 0.75).from(Color.GOLD)
			money_sound.play()
	)
	Events.customer_score_updated.connect(
		func(increased: bool):
			var color: Color
			if increased:
				color = Color.GREEN
				gain_points_sound.play()
			else:
				color = Color.RED
				lose_points_sound.play()
			create_tween().tween_property(customer_happiness_label, "modulate", Color.WHITE, 0.75).from(color)
	)
	Events.player_caught_sprinting.connect(
		func():
			caught_printing_label.text = "-%s🙂 caught sprinting" % Global.penalty_for_sprinting
			caught_printing_label.show()
			await get_tree().create_timer(1, false).timeout
			caught_printing_label.hide()
	)
	Events.player_caught_remaking.connect(
		func():
			caught_remaking_label.text = "-%s🙂 caught remaking drink" % Global.penalty_for_remaking_drink
			caught_remaking_label.show()
			await get_tree().create_timer(1, false).timeout
			caught_remaking_label.hide()
	)
	objective.text = (
		"
		you are the new manager of a fully automated cafe! \n manage the self-service machines and meet your daily objective:
		\n [b]OBJECTIVE:[/b] \n make %s while keeping your customer rating (🙂) above %s
		\n \n if customers get the wrong orders or are kept waiting too long, you might have to deal with them personally!
		\n p.s. your boss is watching on the security cameras !
		"
		% [Global.float_to_price(Global.goal_profit), Global.goal_customer_score]
	)

	await get_tree().create_timer(20, false).timeout
	objective.hide()


func _physics_process(_delta: float) -> void:
	profit_label.text = (
		Global.float_to_price(Global.profit_score)
		+ " (goal: %s)" % Global.float_to_price(Global.goal_profit)
	)
	customer_happiness_label.text = "🙂 " + str(Global.customer_score) + " (goal: %s)" % Global.goal_customer_score
	time_left_label.text = "TIME LEFT: " + str(int(game_timer.time_left))

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


func _on_time_up() -> void:
	if (
		Global.customer_score >= Global.goal_customer_score
		and Global.profit_score >= Global.goal_profit
	):
		end_text.text = "[color=green][b]you win !"
	else:
		end_text.text = "[color=red][b]you lose !"
