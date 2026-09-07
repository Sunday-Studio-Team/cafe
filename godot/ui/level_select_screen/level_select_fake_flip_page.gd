class_name LevelSelectFakeFlipPage
extends Node3D

@export var _page_plane_local_scene: Node3D
@export var _page_mesh_instance: MeshInstance3D

func set_left_page_view(sub_viewport: SubViewport):
	var material: StandardMaterial3D = _page_mesh_instance.get_surface_override_material(1) as StandardMaterial3D
	var texture: ViewportTexture = material.albedo_texture as ViewportTexture
	texture.viewport_path = _page_plane_local_scene.get_path_to(sub_viewport)
	material.albedo_texture = texture

func set_right_page_view(sub_viewport: SubViewport):
	var material: StandardMaterial3D = _page_mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	var texture: ViewportTexture = material.albedo_texture as ViewportTexture
	texture.viewport_path = _page_plane_local_scene.get_path_to(sub_viewport)
	material.albedo_texture = texture
