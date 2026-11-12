class_name ItemLockerModel
extends Node3D

const DOOR_Y_ANGLE_WHEN_CLOSED := 177.3
const DOOR_Y_ANGLE_WHEN_OPEN := 310

@export var door_mesh: MeshInstance3D
@export var fake_mirror_low_fps_updater: LowFpsSubViewportUpdater
@export var fake_mirror_low_fps_updater_override_fps: int

func open_door() -> void:
	fake_mirror_low_fps_updater.override_target_fps(fake_mirror_low_fps_updater_override_fps)
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(
			door_mesh, 
			"rotation:y", 
			deg_to_rad(DOOR_Y_ANGLE_WHEN_OPEN), 
			0.25
	)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	fake_mirror_low_fps_updater.clear_override_target_fps()


func close_door() -> void:
	fake_mirror_low_fps_updater.override_target_fps(fake_mirror_low_fps_updater_override_fps)
	var tween: PropertyTweener = create_tween().set_ease(Tween.EASE_OUT).tween_property(
			door_mesh, 
			"rotation:y", 
			deg_to_rad(DOOR_Y_ANGLE_WHEN_CLOSED),
			0.25
	)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	fake_mirror_low_fps_updater.clear_override_target_fps()
