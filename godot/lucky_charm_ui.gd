extends CanvasLayer

const TIME_TO_SHOW_POPUP_FOR_WHEN_RATING_BLOCKED: float = 4.0

@export var ui_margin_container: MarginContainer
@export var meow_sound: AudioStreamPlayer


func _ready() -> void:
	hide()
	Events.rating_loss_blocked_by_lucky_charm.connect(_play_rating_loss_blocked_animation)


func _play_rating_loss_blocked_animation() -> void:
	show()
	meow_sound.play()
	create_tween().tween_property(
		ui_margin_container,
		"offset_transform_scale",
		Vector2.ONE,
		0.1
	).from(Vector2.ZERO)

	await get_tree().create_timer(
		TIME_TO_SHOW_POPUP_FOR_WHEN_RATING_BLOCKED,
		false
	).timeout

	create_tween().tween_property(
		ui_margin_container,
		"offset_transform_scale",
		Vector2.ZERO,
		0.1
	)
	hide()
