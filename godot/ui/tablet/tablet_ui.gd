class_name TabletUi
extends Control

@export_category("Nodes")
@export var money_made_label: Label
@export var money_bar: ProgressBar
@export var item_icons: Control
@export var rating_meter_stars: Array[TextureProgressBar]
@export var rating_meter_needle: TextureRect
@export_category("Assets")
@export var rating_stars_textures: Array[Texture]
@export var trash_stars: HBoxContainer

var _employee_rating_last_update: float = -1


func _ready() -> void:
	await get_tree().process_frame
	populate_items()
	Events.items_updated.connect(populate_items)

	rating_meter_needle.offset_transform_rotation = deg_to_rad(-135)
	trash_stars.visible = true


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

	money_bar.value = Global.daily_cafe_money / Stats.current.daily_profit_goals_each_day[Global.day] * 100

	if not Global.employee_rating == _employee_rating_last_update:
		_update_rating()


func _update_rating() -> void:
	var current_rating: float = Global.employee_rating
	_employee_rating_last_update = current_rating

	var rotation_for_needle: float = remap(current_rating, 0, 5, -100, 100)
	rating_meter_needle.offset_transform_rotation = deg_to_rad(rotation_for_needle)

	fill_stars(current_rating)


func fill_stars(number_of_stars_to_fill: float) -> void:
	# clear everything first
	for star: TextureProgressBar in rating_meter_stars:
		star.value = 0

	var num_of_whole_stars: int = int(number_of_stars_to_fill)

	for i: int in num_of_whole_stars:
		rating_meter_stars[i].value = 100

	# we'd error if we tried to get rating_meter_stars[5]
	if num_of_whole_stars == 5:
		return

	var value_for_final_star: float = (number_of_stars_to_fill - num_of_whole_stars) * 100

	rating_meter_stars[num_of_whole_stars].value = value_for_final_star
