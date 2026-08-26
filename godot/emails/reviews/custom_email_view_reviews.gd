extends CustomEmailView	
class_name CustomEmailViewReview

@export var review_1: Control
@export var review_list: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var review = Global.reviews.pick_random()
	var container = review_1.duplicate()
	container.review = review
	review_list.add_child(container)
	# remove placeholder
	review_list.remove_child(review_1) 	
