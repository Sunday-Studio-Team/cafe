extends Resource
class_name Review 

@export var username: String
@export var rating: float
@export_multiline var review_content: String
@export var customer_sprite_data_options: Array[CustomerSpriteData]
@export var numbers: int

func _init() -> void:
	numbers = randi_range(2, 999)
