extends Node3D


func _ready() -> void:
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("Door fridge 2Action")
	pass 

func _process(delta: float) -> void:
	pass
