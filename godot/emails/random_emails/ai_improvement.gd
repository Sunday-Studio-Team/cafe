extends Resource
class_name AIImprovement

var stat_bonuses: Dictionary[String, float]
var description: String


func _init(desc: String, bonuses: Dictionary[String, float]) -> void:
	stat_bonuses = bonuses
	description = desc
