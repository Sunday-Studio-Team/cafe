extends CanvasLayer

@export var score_label: Label


func _physics_process(_delta: float) -> void:
	score_label.text = "score: " + str(Global.score)
