@tool
class_name FakeMirror
extends Node

@export var enable_logic: bool = true
@export var enable_match_fov: bool = true

@export var mirror_base_node: Node3D
@export var mirrored_remote_transform: RemoteTransform3D
@export var mirrored_root_node: Node3D
@export var viewpoint_match_node: Node3D
@export var mirrored_camera_3d: Camera3D

@export var debug_viewpoint_marker_3d: Node3D

func _physics_process(delta: float) -> void:
	if !enable_logic:
		return

	if Engine.is_editor_hint():
		var editor_camera: Camera3D = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		_update_visuals(editor_camera)
		_match_camera_fov(editor_camera)
	else:
		if Global.player != null:
			var player_camera: Camera3D = Global.player.camera.camera_effects
			_update_visuals(player_camera)
			_match_camera_fov(player_camera)

func _update_visuals(viewpoint_node_3d: Node3D) -> void:
	# Update the viewpoint match node position and rotation.
	viewpoint_match_node.global_position = viewpoint_node_3d.global_position
	viewpoint_match_node.global_rotation = viewpoint_node_3d.global_rotation
	
	# Update the mirrored camera's local position to match the viewpoint match node's, but invert the z.
	mirrored_camera_3d.position = viewpoint_match_node.position
	mirrored_camera_3d.position.z *= -1.0
	
	# Update the mirrored camera's global rotation to match the viewpoint's after reflection against the mirror.
	var incoming_vec_x: float = rad_to_deg(mirror_base_node.global_rotation.x - viewpoint_match_node.global_rotation.x)
	var reflected_vec_x: float = -mirror_base_node.global_rotation.x - deg_to_rad(incoming_vec_x)
	var incoming_vec_y: float = rad_to_deg(mirror_base_node.global_rotation.y - viewpoint_match_node.global_rotation.y)
	var reflected_vec_y: float = -mirror_base_node.global_rotation.y - deg_to_rad(incoming_vec_y) + deg_to_rad(180.0)
	var reflected_global_rotation: Vector3 = Vector3(reflected_vec_x, -reflected_vec_y, mirrored_camera_3d.global_rotation.z);
	mirrored_camera_3d.global_rotation = reflected_global_rotation

	# Set the near cull boundary to be the distance to the mirror base.
	var distance_to_mirror_base: float = (mirror_base_node.global_position - mirrored_camera_3d.global_position).length()
	const ADDITIONAL_NEAR_CULL: float = 0.2
	mirrored_camera_3d.near = distance_to_mirror_base + ADDITIONAL_NEAR_CULL

func _match_camera_fov(camera_3d: Camera3D) -> void:
	if enable_match_fov:
		mirrored_camera_3d.fov = camera_3d.fov
