extends Resource
class_name Review 

@export var username: String
@export var rating: float
@export_multiline var review_content: String
@export var sprites: Array[AtlasTexture] # W AND H NEEDS TO BE 600X600!!!
@export var numbers: int

func _init() -> void:
	numbers = randi_range(2, 999)
