class_name TrashCan
extends Area3D

var rating_gained: float = 0.2

func _on_body_entered(body: Node3D) -> void:
	# Add logic for giving player points here too
	
	body.remove_from_group("trash_instances")
	body.queue_free()
	Global.employee_rating += rating_gained
	Global.total_trash -= 1
	Events.alert_posted.emit("+%s⭐ Trash cleaned!" % rating_gained, UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_GREEN)
