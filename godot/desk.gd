class_name Desk
extends Node3D

const PC_CAMERA_TWEEN_DURATION := 0.45

@export var interactable: Interactable
@export var fabric_cover_for_monitor: Node3D
@export var camera_spot_for_pc_interaction: Marker3D
@export var pc_ui: PC_UI

var camera_transform_before_pc_interaction: Transform3D


func _ready() -> void:
	await get_tree().process_frame

	interactable.interacted.connect(_on_desk_interacted)
	interactable.show()
	fabric_cover_for_monitor.hide()
	

func _on_desk_interacted() -> void:
	pc_interaction_camera_enter_transition()
	pc_ui.show()

	Events.pc_state_change.emit(true)


# TODO: this (and the below exit func) has similar functionality to the machine
# 3d gui thing, so we should probably just make a global thing and have them all use that
# (it looks goofy and weird to follow when we call this on a `Desk` in pc.gd lool)
func pc_interaction_camera_enter_transition() -> void:
	var cam: CameraController = Global.player.camera
	camera_transform_before_pc_interaction = cam.transform
	create_tween().tween_property(
			cam,
			"global_transform",
			camera_spot_for_pc_interaction.global_transform,
			PC_CAMERA_TWEEN_DURATION,
			)


func pc_interaction_camera_exit_transition() -> void:
	var cam: CameraController = Global.player.camera
	# NOTE: idk why but if i dont set this process mode it bugs . . .
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(
			cam,
			"transform",
			camera_transform_before_pc_interaction,
			PC_CAMERA_TWEEN_DURATION,
			)
	await tween.finished
	cam.sync_rotation_from_player()
