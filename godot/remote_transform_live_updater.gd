@tool
class_name RemoteTransformLiveUpdater
extends Node

@export var remote_transform_3d: RemoteTransform3D
@export var editor_enabled: bool = true

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if editor_enabled:
			if remote_transform_3d == null:
				return
			
			var node3d: Node3D = remote_transform_3d.get_node(remote_transform_3d.remote_path)
			if node3d == null:
				return
			if remote_transform_3d.update_position:
				if remote_transform_3d.use_global_coordinates:
					node3d.global_position = remote_transform_3d.global_position
				else:
					node3d.position = remote_transform_3d.position
			if remote_transform_3d.update_rotation:
				if remote_transform_3d.use_global_coordinates:
					node3d.global_rotation = remote_transform_3d.global_rotation
				else:
					node3d.rotation = remote_transform_3d.rotation
			if remote_transform_3d.update_scale:
				if remote_transform_3d.use_global_coordinates:
					# Unimplemented, unsure of details!
					pass
				else:
					node3d.scale = remote_transform_3d.scale
