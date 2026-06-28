class_name SpillInteractable
extends Interactable

const CLEAN_THRESHOLD := 0.9
const MAX_DRAWABLE_SIZE := 256
const MIN_MOP_UV_DISTANCE_SQ := 0.00008
const SPILL_FOOTPRINT := Vector2(1.65, 1.65)

@export var spill_texture: Texture2D = preload("res://sprites/coffeeblop.png")
@export var erase_shader: Shader = preload("res://shaders/spill_erase_blit.gdshader")
@export var brush_size_px := 48
@export var erase_strength := 0.45
@export var spill_tint := Color(0.45, 0.28, 0.12, 1)

@onready var spill_visual: MeshInstance3D = $SpillVisual
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

var _drawable: DrawableTexture2D
var _spill_material: StandardMaterial3D
var _erase_material: ShaderMaterial
var _brush_texture: ImageTexture
var _texture_size := Vector2i.ZERO
var _initial_spill_amount := 0.0
var _erased_amount := 0.0
var _clean_fraction := 0.0
var _brush_stamp_weight := 0.0
var _brush_size_px := 48
var _last_mop_uv := Vector2(-999.0, -999.0)


func _ready() -> void:
	hold_to_interact = true
	keep_progress_on_interrupt = true
	super._ready()
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true)
	_erase_material = ShaderMaterial.new()
	_erase_material.shader = erase_shader
	_setup_spill_visual()
	reset_spill()


func uses_timer_hold() -> bool:
	return false


func get_custom_hold_progress() -> float:
	return _clean_fraction


func _process_custom_hold(_delta: float) -> void:
	if _mop_at_crosshair():
		_sync_clean_fraction()

	time_held = _clean_fraction * time_to_hold
	if _clean_fraction >= CLEAN_THRESHOLD:
		interacted.emit()
		time_held = 0.0


func reset_spill() -> void:
	_erased_amount = 0.0
	_clean_fraction = 0.0
	time_held = 0.0
	_last_mop_uv = Vector2(-999.0, -999.0)
	_setup_drawable()


func get_interaction_position() -> Vector3:
	return _collision_shape.global_position


func _setup_spill_visual() -> void:
	var plane := PlaneMesh.new()
	plane.size = SPILL_FOOTPRINT
	plane.orientation = PlaneMesh.FACE_Y
	spill_visual.mesh = plane

	_spill_material = StandardMaterial3D.new()
	_spill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_spill_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_spill_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_spill_material.albedo_color = spill_tint
	spill_visual.material_override = _spill_material
	spill_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _setup_drawable() -> void:
	var spill_image := _load_spill_image()
	if spill_image.is_empty():
		push_error("Spill texture has no image data.")
		return

	spill_image = _downscale_image(spill_image)
	_texture_size = spill_image.get_size()
	_drawable = DrawableTexture2D.new()
	_drawable.setup(
		_texture_size.x,
		_texture_size.y,
		DrawableTexture2D.DRAWABLE_FORMAT_RGBA8,
		Color(0, 0, 0, 0),
		false,
	)
	var spill_source := ImageTexture.create_from_image(spill_image)
	_drawable.blit_rect(
		Rect2i(Vector2i.ZERO, _texture_size),
		spill_source,
	)
	_spill_material.albedo_texture = _drawable
	_brush_size_px = brush_size_px
	_brush_texture = _create_soft_brush(_brush_size_px)
	_initial_spill_amount = _estimate_spill_amount(spill_image)
	_sync_clean_fraction()


func _mop_at_crosshair() -> bool:
	if _drawable == null or Global.player == null:
		return false

	var hit_position := _get_mop_surface_point()
	if not hit_position.is_finite() or not _is_point_in_spill_footprint(hit_position):
		return false

	var mop_uv := _world_point_to_mop_uv(hit_position)
	if mop_uv.distance_squared_to(_last_mop_uv) < MIN_MOP_UV_DISTANCE_SQ:
		return false

	var rect := _mop_uv_to_brush_rect(mop_uv)
	if rect.size.x <= 0 or rect.size.y <= 0:
		return false

	_drawable.blit_rect(
		rect,
		_brush_texture,
		Color(1, 1, 1, erase_strength),
		0,
		_erase_material,
	)

	_erased_amount += _brush_stamp_weight
	_last_mop_uv = mop_uv
	return true


func _get_mop_surface_point() -> Vector3:
	var spill_ray: RayCast3D = Global.player.spill_ray
	if spill_ray != null and spill_ray.is_colliding() and spill_ray.get_collider() == self:
		return spill_ray.get_collision_point()

	var aim_ray: RayCast3D = spill_ray if spill_ray != null else Global.player.aiming_ray
	var floor_plane := Plane(Vector3.UP, _collision_shape.global_position.y)
	var intersection = floor_plane.intersects_ray(
		aim_ray.global_position,
		-aim_ray.global_transform.basis.z.normalized(),
	)
	if intersection is Vector3:
		return intersection
	return Vector3.INF


func _is_point_in_spill_footprint(world_point: Vector3) -> bool:
	var local_point := spill_visual.to_local(world_point)
	var half_size := SPILL_FOOTPRINT * 0.5
	return absf(local_point.x) <= half_size.x and absf(local_point.z) <= half_size.y


func _world_point_to_mop_uv(world_point: Vector3) -> Vector2:
	var local_point := spill_visual.to_local(world_point)
	return Vector2(
		(local_point.x / SPILL_FOOTPRINT.x) + 0.5,
		(local_point.z / SPILL_FOOTPRINT.y) + 0.5,
	)


func _mop_uv_to_brush_rect(mop_uv: Vector2) -> Rect2i:
	var u := clampf(mop_uv.x, 0.0, 1.0)
	var v := clampf(mop_uv.y, 0.0, 1.0)
	var center := Vector2i(
		int(u * _texture_size.x),
		int(v * _texture_size.y),
	)
	var half_brush := _brush_size_px >> 1
	var origin := center - Vector2i(half_brush, half_brush)
	return _clamp_rect_to_texture(Rect2i(origin, Vector2i(_brush_size_px, _brush_size_px)))


func _clamp_rect_to_texture(rect: Rect2i) -> Rect2i:
	return rect.intersection(Rect2i(Vector2i.ZERO, _texture_size))


func _sync_clean_fraction() -> void:
	if _initial_spill_amount <= 0.0:
		_clean_fraction = 0.0
		return
	_clean_fraction = clampf(_erased_amount / _initial_spill_amount, 0.0, 1.0)


func _downscale_image(image: Image) -> Image:
	var max_dim := maxi(image.get_width(), image.get_height())
	if max_dim <= MAX_DRAWABLE_SIZE:
		return image.duplicate()
	var scaled := image.duplicate()
	var resize_scale := float(MAX_DRAWABLE_SIZE) / float(max_dim)
	scaled.resize(
		maxi(1, int(image.get_width() * resize_scale)),
		maxi(1, int(image.get_height() * resize_scale)),
		Image.INTERPOLATE_BILINEAR,
	)
	return scaled


func _load_spill_image() -> Image:
	var image := spill_texture.get_image()
	if image.is_empty():
		return image
	if image.is_compressed():
		image = image.duplicate()
		image.decompress()
	return image


func _create_soft_brush(size: int) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size * 0.5, size * 0.5)
	var radius := size * 0.5
	var alpha_sum := 0.0
	for y in size:
		for x in size:
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(center) / radius
			var alpha := clampf(1.0 - dist, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			alpha_sum += alpha
			image.set_pixel(x, y, Color(1, 1, 1, alpha))
	_brush_stamp_weight = alpha_sum * erase_strength
	return ImageTexture.create_from_image(image)


func _estimate_spill_amount(spill_image: Image) -> float:
	var amount := 0.0
	for y in spill_image.get_height():
		for x in spill_image.get_width():
			amount += spill_image.get_pixel(x, y).a
	return maxf(amount, 1.0)
