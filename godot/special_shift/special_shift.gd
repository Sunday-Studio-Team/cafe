class_name SpecialShift
extends Resource

@export var name: String
@export_multiline var description: String
@export var icon: Texture
@export var weight: int
@export_custom(
	PROPERTY_HINT_TYPE_STRING,
	"%d/%d:%s;%d/%d:%s" % [
		TYPE_STRING,
		PROPERTY_HINT_ENUM,
		StatDataEnum.VALUES,
		TYPE_OBJECT,
		PROPERTY_HINT_RESOURCE_TYPE,
		"ModificationData"
	]
)
var modifications: Dictionary[String, ModificationData] = {}



func apply_stats() -> void:
	pass
	# for stat in modifications:
	# 	var current_stat = Stats.current.get(stat)
	# 	if current_stat == null:
	# 		push_error("%s is trying to give a bonus to '%s' but that stat does not exist" % [name, stat])
	# 	if modifications[stat].multiply:
	# 		Stats.current.set(stat, current_stat * modifications[stat].modification)
	# 	else:
	# 		Stats.current.set(stat, current_stat + modifications[stat].modification)


func unapply_stats() -> void:
	pass
	# for stat in modifications:
	# 	var current_stat = Stats.current.get(stat)
	# 	if current_stat == null:
	# 		push_error("%s is trying to take a bonus from '%s' but that stat does not exist" % [name, stat])
	# 	if modifications[stat].multiply:
	# 		Stats.current.set(stat, current_stat / modifications[stat].modification)
	# 	else:
	# 		Stats.current.set(stat, current_stat - modifications[stat].modification)
