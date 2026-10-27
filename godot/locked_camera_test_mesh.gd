## you can attach this to some random test mesh
## or something to test the locked camera mode easily
extends Node3D

var enabled := false
var cam_locked := true:
	set(new):
		if new == true:
			Global.camera_mode = Global.CameraMode.LOCKED_TO_POINT
		else:
			Global.camera_mode = Global.CameraMode.PLAYER
		cam_locked = new


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enabled: return
	
	Global.locked_camera_target_pos = global_position
	Global.camera_mode = Global.CameraMode.LOCKED_TO_POINT


func _physics_process(delta: float) -> void:
	if not enabled: return
	
	if Input.is_action_just_pressed("use_item"):
		cam_locked = !cam_locked