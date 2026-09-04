extends Node3D
@onready var type1_posters: Array[Sprite3D] = [$poster1_type1, $poster2_type1, $poster3_type1]
@onready var type2_posters: Array[Sprite3D] = [$poster4_type2, $poster5_type2, $poster6_type2]
@onready var type3_posters: Array[Sprite3D] = [$poster7_type3, $poster8_type3, $poster9_type3]

func _ready() -> void:
	Events.scene_switch_requested.connect(_on_scene_switch_requested)
	apply_texture(type1_posters, 1)
	apply_texture(type2_posters, 2)
	apply_texture(type3_posters, 3)

func _on_scene_switch_requested(scene: SceneSwitcher.GameScene) -> void:
	# Update posters when switching enviornment
	if scene == SceneSwitcher.GameScene.MAIN_SCENE:
		apply_texture(type1_posters, 1)
		apply_texture(type2_posters, 2)
		apply_texture(type3_posters, 3)
		
func apply_texture(group: Array[Sprite3D], poster_slot: int) -> void:
	var applied_texture := get_poster_path(poster_slot)

	for poster in group:
		poster.texture = applied_texture

func get_poster_path(poster_type: int) -> Texture2D:
	# Clamping so it won't fail after day 5. If more days are added increase this and add more posters in
	var current_day: int = clamp(Global.day, 1, 5)  
	var path := "res://Assets/Posters/day%d_poster%d.png" % [current_day, poster_type]
	return load(path)
