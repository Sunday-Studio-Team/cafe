class_name NonVisibleCameraDisabler
extends Node

@export var _camera_3d: Camera3D
@export var _visible_on_screen_notifier_3d: VisibleOnScreenNotifier3D

func _ready() -> void:
	_visible_on_screen_notifier_3d.screen_entered.connect(_on_notifier_screen_entered)
	_visible_on_screen_notifier_3d.screen_exited.connect(_on_notifier_screen_exited)

func _on_notifier_screen_entered() -> void:
	_camera_3d.visible = true

func _on_notifier_screen_exited() -> void:
	_camera_3d.visible = false
