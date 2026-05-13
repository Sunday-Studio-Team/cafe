extends CanvasLayer

@export var score_label: Label
@export var interactable_label: RichTextLabel


func _physics_process(_delta: float) -> void:
	score_label.text = "score: " + str(Global.score)
	if Global.hovered_interactable != null:
		interactable_label.text = (
			"[E] interact - "
			+ Global.hovered_interactable.display_name
		)
		interactable_label.show()
	else:
		interactable_label.hide()
