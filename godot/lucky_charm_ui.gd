extends CanvasLayer

@export var animation_player: AnimationPlayer


func _ready() -> void:
	hide()

	Events.rating_loss_blocked_by_lucky_charm.connect(
		func() -> void:
			animation_player.play("blocked_rating_loss")
	)
