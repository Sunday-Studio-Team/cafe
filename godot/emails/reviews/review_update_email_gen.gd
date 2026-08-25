extends EmailData
class_name ReviewUpdateEmail

func _init():
	var scene_loader = load("res://emails/reviews/custom_email_view_reviews.tscn")
	var scene: CustomEmailViewReview = scene_loader.instantiate() as CustomEmailViewReview
	day_to_send = Global.day
	is_important = false
	sender_name = "Blep Review"
	displayed_time = "8:30am"
	subject = "Review"
	recipient_name = "Employee #000000"
	custom_email_view_packed_scene = scene_loader
