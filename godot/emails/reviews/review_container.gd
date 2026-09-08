extends Control
class_name ReviewContainer

@export var customer_profile_texture_rect: TextureRect
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
			
			var customer_sprite_data: CustomerSpriteData
			if review.customer_sprite_data_options.size() > 0:
				customer_sprite_data = review.customer_sprite_data_options.pick_random()
			if customer_sprite_data != null:
				var profile_picture: AtlasTexture = customer_sprite_data.generate_email_crop_texture()
				customer_profile_texture_rect.texture = profile_picture
				icon.texture = profile_picture
			else:
				var fallback_profile_picture: Texture2D = review.sprites.pick_random()
				customer_profile_texture_rect.texture = fallback_profile_picture
				icon.texture = fallback_profile_picture
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
