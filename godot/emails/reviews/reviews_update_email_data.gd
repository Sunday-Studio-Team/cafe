class_name ReviewsUpdateEmailData
extends EmailData

@export var email_reviews: Array[Review]

func _init():
	day_to_send = Global.day
	is_important = false
	sender_name = "Blep Reviews"
	displayed_time = "8:30am"
	subject = "Reviews Update"
	recipient_name = "Employee #000000"
	var packed_scene: PackedScene = load("res://emails/reviews/reviews_custom_email_view.tscn")
	custom_email_view_packed_scene = packed_scene
