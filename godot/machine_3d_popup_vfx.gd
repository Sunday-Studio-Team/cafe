class_name Machine3DPopupVfx
extends AnimatedSprite3D

enum VfxType {
	PLUS_RATING,
	MINUS_RATING,
}

@export var _plus_rating_sprite_frames_uid:	StringName
@export var _minus_rating_sprite_frames_uid: StringName

var is_playing_vfx: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	hide()


func play_anim_then_hide(vfx_type: VfxType) -> void:
	if is_playing_vfx:
		return
	
	is_playing_vfx = true
	
	# Lazy load the sprite frames, to save on VRAM when not in use.
	var sprite_frames_uid: StringName
	var animation_name: StringName
	match vfx_type:
		VfxType.PLUS_RATING:
			sprite_frames_uid = _plus_rating_sprite_frames_uid
			animation_name = "plus_rating"
		VfxType.MINUS_RATING:
			sprite_frames_uid = _minus_rating_sprite_frames_uid
			animation_name = "minus_rating"
	var token: ResourceBackgroundLoaderToken = Global.resource_background_loader.cache_resource(sprite_frames_uid)
	while !token.is_loaded:
		await get_tree().process_frame
	var loaded_sprite_frames: SpriteFrames = Global.resource_background_loader.get_resource(token) as SpriteFrames
	Global.resource_background_loader.uncache_resource(token)
	if loaded_sprite_frames == null:
		is_playing_vfx = false
		return
	sprite_frames = loaded_sprite_frames
	
	await get_tree().create_timer(0.5, false).timeout
	scale = Vector3.ZERO
	show()
	play(animation_name)
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(
			self,
			"scale",
			Vector3.ONE,
			0.5
	)


func _on_animation_finished() -> void:
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(
			self,
			"scale",
			Vector3.ZERO,
			0.1
	)
	await t.finished
	hide()
	is_playing_vfx = false
	sprite_frames = null
