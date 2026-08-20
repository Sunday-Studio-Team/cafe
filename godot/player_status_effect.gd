@abstract
class_name PlayerStatusEffect
extends Resource

@abstract
func apply_effect(player: Player) -> void

@abstract
func process_status_effect(delta: float) -> void

@abstract
func is_status_effect_expired() -> bool

@abstract
func get_owner() -> Object
