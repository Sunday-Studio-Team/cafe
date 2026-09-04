@tool
class_name CustomerSpriteData
extends Resource

@export var customer_name: String
@export var sprite: Texture2D
@export var alternate_desk_sprite: Texture2D
@export var typing_minigame_portrait: Texture2D

## Determines the cropped size of the email profile picture, normalized 0.0 to 1.0.
## Uses the shorter dimension (height or width) as the base.
@export var email_crop_size_ratio: float = 1.0:
	get:
		return email_crop_size_ratio
	set(value):
		email_crop_size_ratio = value
		if !Engine.is_editor_hint():
			return
		_editor_update_email_crop_texture()
## Determines the center of the crop for the email profile picture, normalized 0.0 to 1.0. 
@export var email_crop_center_ratio: Vector2 = Vector2(0.5, 0.5):
	get:
		return email_crop_center_ratio
	set(value):
		email_crop_center_ratio = value
		if !Engine.is_editor_hint():
			return
		_editor_update_email_crop_texture()

## Editor only. This will automatically update to give you a preview!
## Adjust `email_crop_size_ratio` and `email_crop_center_ratio`.
@export var editor_email_cropped_sprite_preview: AtlasTexture:
	get:
		if !Engine.is_editor_hint():
			return
		if sprite == null:
			return null
		if _editor_email_cropped_sprite_preview == null:
			_editor_email_cropped_sprite_preview = generate_email_crop_texture()
		return _editor_email_cropped_sprite_preview
	set(value):
		if !Engine.is_editor_hint():
			return
		_editor_email_cropped_sprite_preview = value

var _editor_email_cropped_sprite_preview: AtlasTexture

func generate_email_crop_texture() -> AtlasTexture:
	if sprite == null:
		return null
	
	var customer_sprite: Texture2D = sprite
	var crop_size_ratio: float = email_crop_size_ratio
	var crop_center_ratio: Vector2 = email_crop_center_ratio
	
	var customer_sprite_pixel_size: Vector2 = customer_sprite.get_size()
	var crop_pixel_size: Vector2
	if customer_sprite_pixel_size.x < customer_sprite_pixel_size.y:
		var crop_pixel_width: float = customer_sprite_pixel_size.x * crop_size_ratio
		crop_pixel_size = Vector2(crop_pixel_width, crop_pixel_width)
	else:
		var crop_pixel_height: float = customer_sprite_pixel_size.y * crop_size_ratio
		crop_pixel_size = Vector2(crop_pixel_height, crop_pixel_height)
	var crop_pixel_center: Vector2 = customer_sprite.get_size() * crop_center_ratio
	var crop_pixel_top_left: Vector2 = crop_pixel_center - (crop_pixel_size / 2.0)

	var cropped_texture: AtlasTexture = AtlasTexture.new()
	cropped_texture.atlas = customer_sprite
	cropped_texture.region = Rect2(crop_pixel_top_left, crop_pixel_size)

	return cropped_texture

func _editor_update_email_crop_texture() -> void:
	editor_email_cropped_sprite_preview = generate_email_crop_texture()
