class_name TabletUi
extends Control

@export_category("Nodes")
@export var money_made_label: Label
@export var money_bar: ProgressBar
@export var item_icons: Control
@export var rating_meter_stars: TextureRect
@export var rating_meter_needle: TextureRect
@export_category("Assets")
@export var rating_stars_textures: Array[Texture]

var _employee_rating_last_update: float = -1


func _ready() -> void:
	await get_tree().process_frame
	populate_items()
	Events.items_updated.connect(populate_items)

	rating_meter_stars.texture = rating_stars_textures[0]
	rating_meter_needle.offset_transform_rotation = deg_to_rad(-135)


func populate_items() -> void:
	var i := 0
	for icon: TabletItemIcon in item_icons.get_children():
		if Global.owned_items.size() >= i + 1:
			icon.item = Global.owned_items[i]
		else:
			icon.item = null
		i += 1


func _physics_process(_delta: float) -> void:
	update_score_indicators()


func update_score_indicators() -> void:
	money_made_label.text = "%s/%s" % [
		Global.float_to_price(Global.daily_cafe_money),
		int(Stats.current.daily_profit_goals_each_day[Global.day])
	]

	if Global.daily_cafe_money:
		money_bar.value = Global.daily_cafe_money / Stats.current.daily_profit_goals_each_day[Global.day] * 100

	if not Global.employee_rating == _employee_rating_last_update:
		_update_rating()


func _update_rating() -> void:
	var current_rating: float = Global.employee_rating
	_employee_rating_last_update = current_rating

	rating_meter_stars.texture = rating_stars_textures[current_rating]
	rating_meter_needle.offset_transform_rotation = deg_to_rad(-135 + 45 * current_rating)
