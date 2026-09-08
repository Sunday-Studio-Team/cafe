class_name Whiteboard
extends Node3D

@export var whiteboard_content_container: Container
@export var goal_label: RichTextLabel
@export var info_label: RichTextLabel

@export_multiline var daily_info_text: Array[String]


func _ready() -> void:
	if Global.day == 0:
		whiteboard_content_container.hide()
		return

	goal_label.text = (
		"MAKE [color=green][wave amp=25 freq=2.5]%s"
		% Global.float_to_price(Stats.current.daily_profit_goals_each_day[Global.day])
	)

	info_label.text = daily_info_text[Global.day]
