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
			else:
				color = Color.RED
			create_tween().tween_property(customer_happiness_label, "modulate", Color.WHITE, 0.75).from(color)
	)

	objective.text = (
		"
		you are the new manager of a fully automated cafe! \n manage the self-service machines and meet your daily objective:
		\n [b]OBJECTIVE:[/b] \n make $%s while keeping your customer rating (🙂) above %s
		\n \n if customers get the wrong orders or are kept waiting too long, you might have to deal with them personally!
		"
		% [Global.goal_profit, Global.goal_customer_score]
	)

	await get_tree().create_timer(20, false).timeout
	objective.hide()


func _physics_process(_delta: float) -> void:
	profit_label.text = "$ " + str(Global.profit_score) + " (goal: %s)" % Global.goal_profit
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
