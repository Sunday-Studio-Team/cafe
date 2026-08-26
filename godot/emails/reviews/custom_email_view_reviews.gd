extends CustomEmailView	
class_name CustomEmailViewReview

@export var review_1: Control
@export var review_list: Control

var reviews_list: Array[Review]

var email_day: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !email_day:
		email_day = Global.day
	# Get reviews from today
	reviews_list = Global.recieved_reviews.keys().filter(func(x): return Global.recieved_reviews[x] == email_day)
	for review in reviews_list:
		var container = review_1.duplicate()
		container.review = review
		review_list.add_child(container)
	# remove placeholder
	review_list.remove_child(review_1) 	
