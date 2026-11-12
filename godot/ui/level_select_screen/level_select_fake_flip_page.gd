class_name LevelSelectFakeFlipPage
extends Node3D

@export var _level_select_screen_local_scene: Node
@export var _page_mesh_instance: MeshInstance3D

func set_fake_page_view(sub_viewport: SubViewport):
	var material: StandardMaterial3D = _page_mesh_instance.mesh.surface_get_material(0) as StandardMaterial3D
	var texture: ViewportTexture = material.albedo_texture as ViewportTexture
	texture.viewport_path = _level_select_screen_local_scene.get_path_to(sub_viewport)
	material.albedo_texture = texture
