extends PanelContainer
class_name DrinkInfoContainer

@export var drink_name: Label
@export var drink_price: Label
@export var drink_icon: TextureRect

var drink: Drink = null:
	set(value):
		if value == null:
			drink = null
			drink_icon.texture = null
		else:
			drink = value
			drink_icon.texture = drink.icon
			drink_price.text = str(drink.price)
			drink_price.text = drink.name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
