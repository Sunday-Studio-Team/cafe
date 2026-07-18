extends SubViewportContainer

@export var main_goal: IngredientIconHolder
@export var liquid_goal: IngredientIconHolder
@export var extra_goal: IngredientIconHolder
@export var captcha: GridContainer

func _ready() -> void:
	for child:IngredientIconHolder in captcha.get_children():
		child.ingredient = randi_range(0, Global.main_ingredient_icons.keys().size())
