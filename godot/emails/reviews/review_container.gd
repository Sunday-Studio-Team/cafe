extends Control
class_name ReviewContainer

@export var icon: Sprite2D
@export var username: Label
@export var review_content: RichTextLabel
@export var star_1: TextureRect
@export var reviews_number: Label

var review: Review = null:
	set(value):
		if value == null:
			review = null
			icon.texture = null
		else:
			review = value
			reviews_number.text = "%s Reviews" % review.numbers
			icon.texture = review.sprites.pick_random()
			review_content.text = review.review_content
			username.text = "@" + review.username
			match review.rating:
				0.0:
					star_1.texture = preload("res://sprites/reviews/no_paw_review.png")
				0.5:
					star_1.texture = preload("res://sprites/reviews/half_star.png")
				1.0:
					star_1.texture = preload("res://sprites/reviews/1_star.png")
				1.5:
					star_1.texture = preload("res://sprites/reviews/1_5_star.png")
				2.0:
					star_1.texture = preload("res://sprites/reviews/2_star.png")
				2.5:
					star_1.texture = preload("res://sprites/reviews/2_5_star.png")
				3.0:
					star_1.texture = preload("res://sprites/reviews/3_star.png")
				3.5:
					star_1.texture = preload("res://sprites/reviews/3_5_star.png")
				4.0:
					star_1.texture = preload("res://sprites/reviews/4_star.png")
				4.5:
					star_1.texture = preload("res://sprites/reviews/4_5_star.png")
				5.0:
					star_1.texture = preload("res://sprites/reviews/5_star.png")
				_:
					pass
					
