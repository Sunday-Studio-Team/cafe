extends PanelContainer
class_name ReviewContainer

@export var icon: Sprite2D
@export var username: Label
@export var review_content: RichTextLabel
@export var star_1: TextureRect
@export var stars_grid: GridContainer
@export var reviews_number: Label

var review: Review = null:
	set(value):
		if value == null:
			review = null
			icon.texture = null
		else:
			review = value
			reviews_number.text = "★ %s Reviews" % randi_range(2, 999)
			icon.texture = review.sprites.pick_random()
			review_content.text = review.review_content
			username.text = "@" + review.username
			var star_2 = star_1.duplicate()
			var star_3 = star_1.duplicate()
			var star_4 = star_1.duplicate()
			var star_5 = star_1.duplicate()
			if review.rating >= 1.0:
				star_1.texture = Global.star_texture
				if review.rating == 1.5:
					star_2.texture = Global.half_star_texture
				elif review.rating > 1.5:
					star_2.texture = Global.star_texture
				if review.rating == 2.5:
					star_3.texture = Global.half_star_texture
				elif review.rating > 2.5:
					star_3.texture = Global.star_texture
				if review.rating == 3.5:
					star_4.texture = Global.half_star_texture
				elif review.rating > 3.5:
					star_4.texture = Global.star_texture
				if review.rating == 4.5:
					star_5.texture = Global.half_star_texture
				elif review.rating > 4.5:
					star_5.texture = Global.star_texture
			elif review.rating == 0.5:
				star_1.texture = Global.half_star_texture
			stars_grid.add_child(star_2)
			stars_grid.add_child(star_3)
			stars_grid.add_child(star_4)
			stars_grid.add_child(star_5)
			
func _init(r: Review) -> void:
	review = r
