class_name ItemLocker
extends Node3D

@export var interactable: Interactable
@export var item_locker_model: ItemLockerModel
@export var animation_player: AnimationPlayer
@export var camera_spot: Camera3D
@export var body: StaticBody3D
@export var all_clickable_locker_items: Array[ClickableLockerItem]

const CAM_TWEEN_DURATION:float = 0.45

var exiting_loadout: bool = false
var camera_transform_before_locker_interaction: Transform3D
var connected_items: Array[ClickableLockerItem]

func _ready() -> void:
	# if we haven't beaten day 1
	# (we want to have the locker if we're replaying day 1 after beating it, but not before)
	if SaveDataManager.save_data.latest_unlocked_day <= 1:
		hide()
		process_mode = ProcessMode.PROCESS_MODE_DISABLED

	Global.item_locker = self

	Events.shift_started.connect(
			func() -> void:
				interactable.hide()
	)
	interactable.interacted.connect(interaction_camera_enter_transition)

func interaction_camera_enter_transition() -> void:
	interactable.visible = false
	body.process_mode = Node.PROCESS_MODE_DISABLED
	var cam: CameraController = Global.player.camera
	camera_transform_before_locker_interaction = cam.transform
	create_tween().tween_property(
			cam,
			"global_transform",
			camera_spot.global_transform,
			CAM_TWEEN_DURATION,
			)


func interaction_camera_exit_transition() -> void:
	interactable.visible = true
	body.process_mode = Node.PROCESS_MODE_INHERIT
	exiting_loadout = true
	var cam: CameraController = Global.player.camera
	# NOTE: idk why but if i dont set this process mode it bugs . . .
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(
			cam,
			"transform",
			camera_transform_before_locker_interaction,
			CAM_TWEEN_DURATION,
			)
	await tween.finished
	cam.sync_rotation_from_player()
	exiting_loadout = false
