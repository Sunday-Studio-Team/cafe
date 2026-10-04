class_name TrashCan
extends Area3D

@export var trash_can_model: MeshInstance3D
@export var highlight_material: Material
@export var scored_sfx: AudioStreamPlayer3D

var rating_gained: float = 0.2
var surface_index := 0
var feedback_tween: Tween
var trash_can_original_scale: Vector3
var squish_duration := 0.08
var stretching_duration := 0.1
var recover_duration := 0.12

func _ready() -> void:
	trash_can_original_scale = trash_can_model.scale
	trash_can_model.set_surface_override_material(surface_index, null)
	Events.pickup_trash.connect(
		func():
			trash_can_model.set_surface_override_material(surface_index, highlight_material)
	)
	Events.throw_trash.connect(
		func():
			trash_can_model.set_surface_override_material(surface_index, null)
	)


func _on_body_entered(body: Node3D) -> void:
	# Add logic for giving player points here too
	body.remove_from_group("trash_instances")
	body.queue_free()
	scored_sfx.play()
	Global.employee_rating += rating_gained
	Global.total_trash -= 1
	play_feedback()


func play_feedback() -> void:
	if feedback_tween != null and feedback_tween.is_running():
		return

	feedback_tween = create_tween()

	feedback_tween.tween_property(
		trash_can_model,
		"scale",
		trash_can_original_scale * Vector3(1.15, 0.75, 1.15),
		squish_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	feedback_tween.tween_property(
		trash_can_model,
		"scale",
		trash_can_original_scale * Vector3(0.9, 1.2, 0.9),
		stretching_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	feedback_tween.tween_property(
		trash_can_model,
		"scale",
		trash_can_original_scale,
		recover_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Events.alert_posted.emit("+%s⭐ Trash cleaned!" % rating_gained, UI.AlertIconType.RATING, UI.ALERT_DEFAULT_DURATION, UI.ALERT_COLOR_GREEN)
