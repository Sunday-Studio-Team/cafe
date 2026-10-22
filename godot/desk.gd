class_name Desk
extends Node3D

const PC_CAMERA_TWEEN_DURATION := 0.45

@export var interactable: Interactable
@export var fabric_cover_for_monitor: Node3D
@export var camera_spot_for_pc_interaction: Marker3D
@export var email_notif_animated_sprite: AnimatedSprite3D

var camera_transform_before_pc_interaction: Transform3D
var exiting_pc: bool = false

func _ready() -> void:
	Global.desk = self

	await get_tree().process_frame

	if Global.unread_email_count > 0:
		email_notif_animated_sprite.visible = true
		email_notif_animated_sprite.play("unread_emails_idle")
	else:
		email_notif_animated_sprite.visible = false

	interactable.interacted.connect(_on_desk_interacted)
	interactable.show()
	fabric_cover_for_monitor.hide()

	Events.shift_started.connect(_on_shift_started)


func _process(_delta: float) -> void:
	if Global.unread_email_count > 0:
		email_notif_animated_sprite.visible = true
	else:
		email_notif_animated_sprite.visible = false


func _on_desk_interacted() -> void:
	if exiting_pc: return
	pc_interaction_camera_enter_transition()
	Global.pc_ui.show()

	Events.pc_state_change.emit(true)


func _on_shift_started() -> void:
	interactable.visible = false


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
	exiting_pc = true
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
	exiting_pc = false
