extends Node2D

@export var canvas_sprite: Sprite2D
@export var progress_label: Label
@export var mop_sprite: DraggableMop
@export var moping_area: Area2D
@export var bucket: Sprite2D
@export var mop: DraggableMop
@export var splash: AudioStreamPlayer2D
# 0.0 means every visible pixel must be erased.
# You could use 0.01 to allow 1% of the image to remain.
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio: float# = Stats.current.clean_spill_allowed_remaining


# If a pixel has alpha value lower then the threshold,
# it was consider transparent
const ALPHA_THRESHOLD_BYTE: int = 5

var mop_collision: CollisionShape2D
var mop_rectangle: RectangleShape2D
var canvas_image: Image
var canvas_texture: ImageTexture
var starting_pixel_count: int = 0
var remaining_pixel_count: int = 0

var image_width: int
var image_height: int
var pixel_data: PackedByteArray

var is_erasing: bool = false
var game_finished: bool = false


func _ready() -> void:
	Global.minigame_active = true
	canvas_sprite.texture = Global.spill_sprites.pick_random()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	canvas_image = canvas_sprite.texture.get_image()
	canvas_image.convert(Image.FORMAT_RGBA8)
	canvas_image.clear_mipmaps()

	image_width = canvas_image.get_width()
	image_height = canvas_image.get_height()
	pixel_data = canvas_image.get_data()

	canvas_texture = ImageTexture.create_from_image(canvas_image)
	canvas_sprite.texture = canvas_texture

	mop_collision = moping_area.get_child(0) as CollisionShape2D
	mop_rectangle = mop_collision.shape as RectangleShape2D

	if moping_area == null:
		push_error("Moping Area has not been assigned.")
		set_physics_process(false)
		return

	mop_collision = (moping_area.get_child(0) as CollisionShape2D)

	if mop_collision == null:
		push_error("Moping Area must have a CollisionShape2D child.")
		set_physics_process(false)
		return

	mop_rectangle = (mop_collision.shape as RectangleShape2D)

	if mop_rectangle == null:
		push_error("The CollisionShape2D must use RectangleShape2D.")
		set_physics_process(false)
		return
	
	if mop == null:
		push_error("Mop has not been assigned")
		set_physics_process(false)
		return

	mop_sprite.drag_started.connect(_on_mop_drag_started)
	mop_sprite.drag_ended.connect(_on_mop_drag_ended)

	count_starting_pixels()
	update_progress_display()


func _physics_process(_delta: float) -> void:
	if game_finished or not is_erasing:
		return

	if mop_collision == null or mop_collision.disabled:
		return

	# The mop cannot erase until it has touched the bucket.
	if not mop.is_wet:
		if mop_overlaps_bucket():
			splash.play()
			mop.is_wet = true
			mop.modulate = "5f5f5f"
			mop.bubbles.emitting = true
			print("The mop is now wet.")
		return

	var image_changed: bool = erase_inside_mop_rectangle()

	if not image_changed:
		return

	upload_changed_image()
	update_progress_display()
	check_for_win()


func _on_mop_drag_started() -> void:
	is_erasing = true


func _on_mop_drag_ended() -> void:
	is_erasing = false

func mop_overlaps_bucket() -> bool:
	if bucket == null or bucket.texture == null:
		return false

	var half_size: Vector2 = mop_rectangle.size * 0.5

	var mop_local_rect: Rect2 = Rect2(
		-half_size,
		mop_rectangle.size
	)

	var bucket_local_rect: Rect2 = bucket.get_rect()

	var mop_polygon: PackedVector2Array = (
		rect_to_global_polygon(
			mop_local_rect,
			mop_collision.global_transform
		)
	)

	var bucket_polygon: PackedVector2Array = (
		rect_to_global_polygon(
			bucket_local_rect,
			bucket.global_transform
		)
	)

	var intersection: Array[PackedVector2Array] = (
		Geometry2D.intersect_polygons(
			mop_polygon,
			bucket_polygon
		)
	)

	return not intersection.is_empty()


func rect_to_global_polygon(local_rect: Rect2, global_rect_transform: Transform2D) -> PackedVector2Array:
	var top_left: Vector2 = (
		global_rect_transform
		* local_rect.position
	)

	var top_right: Vector2 = (
		global_rect_transform
		* Vector2(
			local_rect.end.x,
			local_rect.position.y
		)
	)

	var bottom_right: Vector2 = (
		global_rect_transform
		* local_rect.end
	)

	var bottom_left: Vector2 = (
		global_rect_transform
		* Vector2(
			local_rect.position.x,
			local_rect.end.y
		)
	)

	return PackedVector2Array([
		top_left,
		top_right,
		bottom_right,
		bottom_left
	])


func erase_inside_mop_rectangle() -> bool:
	var sprite_rect: Rect2 = canvas_sprite.get_rect()
	var half_size: Vector2 = mop_rectangle.size * 0.5

	# Converts a point from the collision shape's local coordinates
	# into the sprite's local coordinates.
	var shape_to_sprite: Transform2D = (
		canvas_sprite.global_transform.affine_inverse()
		* mop_collision.global_transform
	)

	# Converts a point from the sprite's local coordinates
	# into the collision shape's local coordinates.
	var sprite_to_shape: Transform2D = (
		shape_to_sprite.affine_inverse()
	)

	var shape_bounds: Rect2 = Rect2(
		-half_size,
		mop_rectangle.size
	)

	var bounds_on_sprite: Rect2 = transform_rect(
		shape_bounds,
		shape_to_sprite
	)

	var clipped_bounds: Rect2 = (
		bounds_on_sprite.intersection(sprite_rect)
	)

	if not clipped_bounds.has_area():
		return false

	var pixel_bounds: Rect2i = sprite_rect_to_pixel_rect(
		clipped_bounds,
		sprite_rect
	)

	var image_changed: bool = false

	for y: int in range(
		pixel_bounds.position.y,
		pixel_bounds.end.y
	):
		for x: int in range(
			pixel_bounds.position.x,
			pixel_bounds.end.x
		):
			var pixel_number: int = y * image_width + x
			var alpha_index: int = pixel_number * 4 + 3

			if pixel_data[alpha_index] <= ALPHA_THRESHOLD_BYTE:
				continue

			var sprite_point: Vector2 = pixel_to_sprite_position(
				x,
				y,
				sprite_rect
			)

			var shape_point: Vector2 = (
				sprite_to_shape * sprite_point
			)

			var is_inside: bool = (
				absf(shape_point.x) <= half_size.x
				and absf(shape_point.y) <= half_size.y
			)

			if not is_inside:
				continue

			pixel_data[alpha_index] = 0
			remaining_pixel_count -= 1
			image_changed = true

	return image_changed


func transform_rect(
		rect: Rect2,
		rect_transform: Transform2D
) -> Rect2:
	var top_left: Vector2 = (
		rect_transform * rect.position
	)

	var top_right: Vector2 = (
		rect_transform
		* Vector2(rect.end.x, rect.position.y)
	)

	var bottom_right: Vector2 = (
		rect_transform * rect.end
	)

	var bottom_left: Vector2 = (
		rect_transform
		* Vector2(rect.position.x, rect.end.y)
	)

	var result: Rect2 = Rect2(
		top_left,
		Vector2.ZERO
	)

	result = result.expand(top_right)
	result = result.expand(bottom_right)
	result = result.expand(bottom_left)

	return result
	


func sprite_rect_to_pixel_rect(
		bounds: Rect2,
		sprite_rect: Rect2
) -> Rect2i:
	var normalized_start: Vector2 = (
		(bounds.position - sprite_rect.position)
		/ sprite_rect.size
	)

	var normalized_end: Vector2 = (
		(bounds.end - sprite_rect.position)
		/ sprite_rect.size
	)

	normalized_start.x = clampf(
		normalized_start.x,
		0.0,
		1.0
	)

	normalized_start.y = clampf(
		normalized_start.y,
		0.0,
		1.0
	)

	normalized_end.x = clampf(
		normalized_end.x,
		0.0,
		1.0
	)

	normalized_end.y = clampf(
		normalized_end.y,
		0.0,
		1.0
	)

	var start_x: int = clampi(
		floori(normalized_start.x * image_width),
		0,
		image_width
	)

	var start_y: int = clampi(
		floori(normalized_start.y * image_height),
		0,
		image_height
	)

	var end_x: int = clampi(
		ceili(normalized_end.x * image_width),
		0,
		image_width
	)

	var end_y: int = clampi(
		ceili(normalized_end.y * image_height),
		0,
		image_height
	)

	return Rect2i(
		start_x,
		start_y,
		end_x - start_x,
		end_y - start_y
	)


func pixel_to_sprite_position(
		x: int,
		y: int,
		sprite_rect: Rect2
) -> Vector2:
	var normalized_position: Vector2 = Vector2(
		(float(x) + 0.5) / float(image_width),
		(float(y) + 0.5) / float(image_height)
	)

	return (
		sprite_rect.position
		+ normalized_position * sprite_rect.size
	)


func upload_changed_image() -> void:
	canvas_image.set_data(
		image_width,
		image_height,
		false,
		Image.FORMAT_RGBA8,
		pixel_data
	)
	canvas_texture.update(canvas_image)


func count_starting_pixels() -> void:
	starting_pixel_count = 0

	for pixel_index: int in range(image_width * image_height):
		var alpha_index: int = pixel_index * 4 + 3

		if pixel_data[alpha_index] > ALPHA_THRESHOLD_BYTE:
			starting_pixel_count += 1

	remaining_pixel_count = starting_pixel_count


func update_progress_display() -> void:
	if starting_pixel_count <= 0:
		progress_label.text = "Erased: 100%"
		return

	var remaining_ratio: float = (
			float(remaining_pixel_count)
			/ float(starting_pixel_count)
	)

	var erased_ratio: float = 1.0 - remaining_ratio

	var erased_percentage: int = roundi(erased_ratio * 100.0)

	progress_label.text = ("Erased: %d%%" % erased_percentage)


func check_for_win() -> void:
	if starting_pixel_count <= 0:
		win_game()
		return

	var remaining_ratio: float = (
			float(remaining_pixel_count)
			/ float(starting_pixel_count)
	)

	if remaining_ratio <= allowed_remaining_ratio:
		win_game()


func win_game() -> void:
	if game_finished:
		return

	game_finished = true
	is_erasing = false

	progress_label.text = "Erased: 100%"

	Events.emit_signal("minigame_end")
