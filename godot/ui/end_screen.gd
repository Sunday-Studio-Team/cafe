extends CanvasLayer

@export var times_up: RichTextLabel
@export var shift_cleared: RichTextLabel
@export var shift_failed: RichTextLabel
@export var time_up_sound: AudioStreamPlayer
@export var win_shift_sound: AudioStreamPlayer
@export var lose_shift_sound: AudioStreamPlayer


func _ready() -> void:
	Events.time_up.connect(_on_time_up)


func _on_time_up() -> void:
	get_tree().paused = true
	times_up.show()
	#time_up_sound.play()
	await get_tree().create_timer(2).timeout
	times_up.hide()

	if (
		Stats.daily_profit >= Stats.daily_profit_goal
		and Stats.employee_rating >= Stats.employee_rating_goal
	):
		shift_cleared.show()
		win_shift_sound.play()
	else:
		shift_failed.show()
		lose_shift_sound.play()
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	Events.end_screen_finished.emit()
