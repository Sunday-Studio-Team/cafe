class_name LevelSelectPageSpread
extends Node3D

@export var _left_page_mesh_instance: MeshInstance3D
@export var _right_page_mesh_instance: MeshInstance3D

func set_left_page_view(sub_viewport: SubViewport):
	var material: StandardMaterial3D = _left_page_mesh_instance.mesh.surface_get_material(0) as StandardMaterial3D
	var texture: ViewportTexture = material.albedo_texture as ViewportTexture
	texture.viewport_path = sub_viewport.get_path()

func set_right_page_view(sub_viewport: SubViewport):
	var material: StandardMaterial3D = _right_page_mesh_instance.mesh.surface_get_material(0) as StandardMaterial3D
	var texture: ViewportTexture = material.albedo_texture as ViewportTexture
	texture.viewport_path = sub_viewport.get_path()
