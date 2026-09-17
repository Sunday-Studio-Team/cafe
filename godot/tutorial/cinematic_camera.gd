class_name CinematicCamera
extends Node3D

signal animation_finished

@export var cinematic_bars: CinematicBars
@export var camera_rig_node: Node3D

@export var _camera_3d: Camera3D
@export var _animation_player: AnimationPlayer
@export var _player_ui_sub_viewport_container: Control
@export var _player_ui_sub_viewport: SubViewport

var _camera_target_fov: float

func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_player_finished)

	_camera_target_fov = _camera_3d.fov

func enable_cinematic_camera(fov_transition_duration: float = 1.0) -> void:
	Global.camera_mode = Global.CameraMode.CINEMATIC
	Global.cinematic_camera_allow_machine_gui_inputs = false
	Global.player.free_cam_visualizer.visible = true
	_player_ui_sub_viewport_container.visible = false
	_camera_3d.make_current()
	await create_tween().tween_property(_camera_3d, "fov", _camera_target_fov, fov_transition_duration).finished

func disable_cinematic_camera(fov_transition_duration: float = 1.0) -> void:
	await create_tween().tween_property(_camera_3d, "fov", Global.player.camera.camera_effects.fov, fov_transition_duration).finished
	Global.camera_mode = Global.CameraMode.PLAYER
	Global.cinematic_camera_allow_machine_gui_inputs = true
	Global.player.free_cam_visualizer.visible = false
	_player_ui_sub_viewport_container.visible = true
	Global.player.camera.camera_effects.make_current()

func play_animation(animation_name: StringName) -> void:
	_animation_player.play(animation_name)
	await _animation_player.animation_finished

func _on_animation_player_finished(animation_name: StringName) -> void:
	animation_finished.emit()
