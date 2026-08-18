class_name Item
extends Resource

@export var item_id: String
@export var name: String
@export var description_at_levels: Dictionary[int, String]
@export var icon: Texture
@export var price_at_levels: Dictionary[int, float]
@export var sell_value_at_levels: Dictionary[int, float]
## this will be for 'active items' we can pick up
## NOTE: unused as of now
@export var in_game_item: PackedScene
#Active Items
@export var is_active_item: bool = false
@export var active_item_cooldown_at_levels: Dictionary[int, float]
# if true, we show a buttom prompt to press Q to use the item whenever its equipped
# (disable for items like the hammer which can only be used on other objects etc)
# NOTE: only relevant for active items
@export var can_activate_anywhere: bool = true

var item_level: int = 1
var active_item_remaining_cooldown: float
var can_be_used: bool = true #Set to false when the item is used


func apply_stats() -> void:
	if item_id == "roller_skates":
		if item_level == 1:
			Stats.current.default_move_speed *= 2.0
			Stats.current.player_accel -= 10.0
			Stats.current.player_decel -= 10.0
		elif item_level == 2:
			Stats.current.default_move_speed *= 3.0
			Stats.current.player_accel -= 10.0
			Stats.current.player_decel -= 10.0


# for when we sell items
func unapply_stats() -> void:
	if item_id == "roller_skates":
		if item_level == 1:
			Stats.current.default_move_speed /= 2.0
			Stats.current.player_accel += 10.0
			Stats.current.player_decel += 10.0
		elif item_level == 2:
			Stats.current.default_move_speed /= 3.0
			Stats.current.player_accel += 10.0
			Stats.current.player_decel += 10.0
