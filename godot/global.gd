extends Node

var player: Player
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var score: int = 0


# NOTE: this is probably rlly stupid . will probably replace with resources or
# something
func _ready() -> void:
	var latte := Drink.new()
	latte.drink_name = "latte"
	latte.main_ingredient = Drink.MainIngredient.COFFEE
	latte.liquid = Drink.Liquid.MILK
	drinks.append(latte)

	var iced_latte := Drink.new()
	iced_latte.drink_name = "iced latte"
	iced_latte.main_ingredient = Drink.MainIngredient.COFFEE
	iced_latte.liquid = Drink.Liquid.MILK
	iced_latte.extra = Drink.Extra.ICE
	drinks.append(iced_latte)

	var chai_latte := Drink.new()
	chai_latte.drink_name = "chai latte"
	chai_latte.main_ingredient = Drink.MainIngredient.CHAI
	chai_latte.liquid = Drink.Liquid.MILK
	# NOTE: should this have sugar ? idk
	chai_latte.extra = Drink.Extra.SUGAR
	drinks.append(chai_latte)

	var black_tea := Drink.new()
	black_tea.drink_name = "black tea"
	black_tea.main_ingredient = Drink.MainIngredient.TEA
	black_tea.liquid = Drink.Liquid.WATER
	drinks.append(black_tea)

	var black_coffee := Drink.new()
	black_coffee.drink_name = "black coffee"
	black_coffee.main_ingredient = Drink.MainIngredient.COFFEE
	black_coffee.liquid = Drink.Liquid.WATER
	drinks.append(black_coffee)

	var espresso := Drink.new()
	espresso.drink_name = "espresso"
	espresso.main_ingredient = Drink.MainIngredient.COFFEE
	drinks.append(espresso)

	var chai := Drink.new()
	chai.drink_name = "chai"
	chai.main_ingredient = Drink.MainIngredient.CHAI
	chai.liquid = Drink.Liquid.WATER
