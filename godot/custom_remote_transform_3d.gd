@tool
class_name CustomRemoteTransform3D
extends Node

@export var reference_node_3d: Node3D
@export var target_node_3d: Node3D
@export var should_update_position: bool = true
@export var should_update_rotation: bool = true
@export var should_update_scale: bool = true
@export var use_global_coordinates: bool = true

@export var editor_enabled: bool = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not editor_enabled:
		return
	
	if reference_node_3d == null:
		return
	
	if target_node_3d == null:
		return
	if should_update_position:
		if use_global_coordinates:
			target_node_3d.global_position = reference_node_3d.global_position
		else:
			target_node_3d.position = reference_node_3d.position
	if should_update_rotation:
		if use_global_coordinates:
			target_node_3d.global_rotation = reference_node_3d.global_rotation
		else:
			target_node_3d.rotation = reference_node_3d.rotation
	if should_update_scale:
		if use_global_coordinates:
			# Unimplemented, unsure of details!
			pass
		else:
			target_node_3d.scale = reference_node_3d.scale
	
	if not Engine.is_editor_hint():		
		print("reference_node_3d.global_position: %s" % reference_node_3d.global_position)
		print("camera_target_3d.global_position: %s" % target_node_3d.global_position)
