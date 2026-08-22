class_name PlayerStatusEffects
extends Resource

var _player: Player
var _player_status_effects_array: Array[PlayerStatusEffect] = []

func _init(player: Player) -> void:
	_player = player
	_reset_stats()

func has_status_effect_from_owner(owner: RefCounted) -> bool:
	for status_effect in _player_status_effects_array:
		if status_effect.get_owner() == owner:
			return true
	return false

func recalculate_status_effects() -> void:
	_reset_stats()
	_apply_status_effects()

func apply_status_effect(status_effect: PlayerStatusEffect) -> void:
	_reset_stats()
	_player_status_effects_array.append(status_effect)
	_apply_status_effects()

func remove_status_effect(status_effect: PlayerStatusEffect) -> void:
	var index: int = _player_status_effects_array.find(status_effect)
	if index == -1:
		return
	_player_status_effects_array.remove_at(index)
	_reset_stats()
	_apply_status_effects()

func process_status_effects(delta: float) -> void:
	for i in range(_player_status_effects_array.size()):
		if i >= _player_status_effects_array.size():
			return
		var status_effect: PlayerStatusEffect = _player_status_effects_array[i]
		status_effect.process_status_effect(delta)
		if status_effect.is_status_effect_expired():
			remove_status_effect(status_effect)
		else:
			i += 1

func _reset_stats() -> void:
	# Reset to base stats
	_player._walk_move_speed = Stats.current.default_move_speed
	_player._sprint_move_speed = Stats.current.sprint_move_speed

func _apply_status_effects() -> void:
	for player_status_effect in _player_status_effects_array:
		player_status_effect.apply_effect(_player)
