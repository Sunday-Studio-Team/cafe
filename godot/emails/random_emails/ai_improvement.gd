extends Resource
class_name AIImprovement

@export_custom(PROPERTY_HINT_TYPE_STRING, "4/3:%s;3:" % StatDataEnum.VALUES) var stat_bonuses: Dictionary[String, float]

func _add(stat_to_change: String, amount: float)  -> void:
	stat_bonuses[str(stat_to_change)] = amount
