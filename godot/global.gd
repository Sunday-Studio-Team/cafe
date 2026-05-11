extends Node

var player: Player
var main_scene: Node3D
var customer_entry_spot: Marker3D
var customer_leaving_spot: Marker3D
var drinks: Array[Drink]
var score: int = 0


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
	chai_latte.extra = Drink.Extra.SUGAR
	drinks.append(chai_latte)
