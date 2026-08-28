class_name ReviewsCustomEmailView
extends CustomEmailView

@export var review_1: Control
@export var review_list: Control

var _reviews_update_email_data: ReviewsUpdateEmailData

func setup_reviews(reviews_update_email_data: ReviewsUpdateEmailData) -> void:
	_reviews_update_email_data = reviews_update_email_data
	var reviews_list: Array[Review] = reviews_update_email_data.email_reviews
	for review in reviews_list:
		var container = review_1.duplicate()
		container.review = review
		review_list.add_child(container)
	# remove placeholder
	review_list.remove_child(review_1)
	
