extends CanvasLayer

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
@export var caught_printing_label: Label
@export var caught_remaking_label: Label
@export var cctv_indicator: TextureRect


func _ready() -> void:
	Events.time_up.connect(_on_time_up)
	Events.money_updated.connect(
		func(_new_value: float, change: float, message: String):
			var color: Color
			create_tween().tween_property(profit_label, "modulate", Color.WHITE, 0.75).from(Color.GOLD)
			if change > 0:
				color = Color.GREEN
				score_update_label.text = "+"
			else:
				color = Color.RED
				score_update_label.text = "-"
			score_update_label.text += "$%s %s" % [abs(int(change)), message]
			create_tween().tween_property(profit_label, "modulate", Color.WHITE, 0.75).from(color)
			score_update_label.modulate = color
			create_tween().tween_property(score_update_label, "modulate:a", 0, 1.5)
			money_sound.play()
	)
	Events.customer_score_updated.connect(
		func(_new_value: float, change: float, message: String):
			var color: Color
			if change > 0:
				color = Color.GREEN
				gain_points_sound.play()
				score_update_label.text = "+"
			else:
				color = Color.RED
				lose_points_sound.play()
				score_update_label.text = "-"
			score_update_label.text += "🙂%s %s" % [abs(int(change)), message]
			create_tween().tween_property(customer_happiness_label, "modulate", Color.WHITE, 0.75).from(color)
			score_update_label.modulate = color
			create_tween().tween_property(score_update_label, "modulate:a", 0, 1.5)
	)
	objective.text = (
		"you are the new manager of a fully automated cafe!
		[b]OBJECTIVE[/b] \n make %s while keeping your customer rating (🙂) above %s \n
		if customers don't get good service, you might have to deal with them personally!
		p.s. your boss is watching on the security cameras, so follow the rules."
		% [Global.float_to_price(Global.goal_profit), Global.goal_customer_score]
	)
	score_update_label.modulate = Color.TRANSPARENT
	await get_tree().create_timer(20, false).timeout
	objective.hide()


func _physics_process(_delta: float) -> void:
	update_score_indicators()
	update_interactable_ui()
	update_time_indicator()
	update_cctv_indicator()


func update_score_indicators() -> void:
	profit_label.text = (
		Global.float_to_price(Global.profit_score)
		+ " (goal: %s)" % Global.float_to_price(Global.goal_profit)
	)
	customer_happiness_label.text = "🙂 " + str(Global.customer_score) + " (goal: %s)" % Global.goal_customer_score


func update_time_indicator() -> void:
	time_left_label.text = "TIME LEFT: %ss" % int(game_timer.time_left)


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


func _on_time_up() -> void:
	if (
		Global.customer_score >= Global.goal_customer_score
		and Global.profit_score >= Global.goal_profit
	):
		end_text.text = "[color=green][b]you win !"
	else:
		end_text.text = "[color=red][b]you lose !"
