extends PanelContainer
class_name ReviewContainer

@export var icon: Sprite2D
@export var username: Label
@export var review_content: RichTextLabel

var review: Review = null:
	set(value):
		if value == null:
			review = null
			icon.texture = null
		else:
			review = value
			icon.texture = review.sprite
			review_content.text = review.review_content
			username.text = "@" + review.username

func init(r: Review) -> void:
	review = r
