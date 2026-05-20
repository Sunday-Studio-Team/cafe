extends CanvasLayer

@export var score_label: Label
@export var interactable_indicator: PanelContainer
@export var interactable_label: RichTextLabel
@export var hold_interact_progress: ProgressBar
@export var game_timer: Timer
@export var time_left_label: Label
@export var objective: RichTextLabel
@export var end_text: RichTextLabel


func _ready() -> void:
	Events.time_up.connect(_on_time_up)

	objective.text = (
		"[b]OBJECTIVE:[/b] \n \n score %s points before the timer ends !"
		% Global.goal_score
	)

	await get_tree().create_timer(5, false).timeout
	objective.hide()


func _physics_process(_delta: float) -> void:
	score_label.text = "score: " + str(Global.score)
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
	if Global.score >= Global.goal_score:
		end_text.text = "[color=green][b]you win !"
	else:
		end_text.text = "[color=red][b]you lose !"
