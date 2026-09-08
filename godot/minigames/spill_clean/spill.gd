class_name ErasableCanvas
extends Node2D


@export var canvas_sprite: Sprite2D
@export var progress_label: Label
@export var moping_area: Area2D
@export var bucket: Sprite2D
@export var bucket_area: Area2D
@export var mop: DraggableMop


# 0.0 means every visible pixel must be erased.
# You could use 0.01 to allow 1% of the image to remain.
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio: float # = Stats.current.clean_spill_allowed_remaining
var mop_collision: CollisionShape2D
var mop_rectangle: RectangleShape2D
var canvas_image: Image
var canvas_texture: ImageTexture
var starting_pixel_count: int = 0
var remaining_pixel_count: int = 0
var image_width: int
var image_height: int
var game_finished: bool = false
var previous_mop_position := Vector2.INF
var remaining_mask: BitMap


func _ready() -> void:
	Global.minigame_active = true
	Global.in_spill_minigame = true
	canvas_sprite.texture = Global.spill_sprites.pick_random()

	canvas_image = canvas_sprite.texture.get_image()
	canvas_image.convert(Image.FORMAT_RGBA8)
	canvas_image.clear_mipmaps()

	image_width = canvas_image.get_width()
	image_height = canvas_image.get_height()

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

	bucket_area.area_entered.connect(
		func(_area: Area2D):
			mop.wet_mop()
	)

	initialize_progress_mask()
	update_progress_display()


func _physics_process(_delta: float) -> void:
	if game_finished or not mop.is_wet:
		return

	if mop_collision == null or mop_collision.disabled:
		return
	
	if mop_collision.global_position.distance_to(previous_mop_position) < 50.0:
		return

	var rect: Rect2i = erased_area_inside_mop_rectangle()
	
	previous_mop_position = mop_collision.global_position

	update_image(rect)
	update_progress_display()
	check_for_win()


func erased_area_inside_mop_rectangle() -> Rect2i:
	var half_size := mop_rectangle.size / 2.0

	var shape_to_sprite := (
		canvas_sprite.global_transform.affine_inverse()
		* mop_collision.global_transform
	)

	var top_left := shape_to_sprite * -half_size
	var bottom_right := shape_to_sprite * half_size

	var image_half_size := Vector2(image_width, image_height) / 2.0

	top_left += image_half_size
	bottom_right += image_half_size

	return Rect2i(top_left, bottom_right - top_left).abs()


func update_image(rect: Rect2i) -> void:
	var image_rect := Rect2i(
		Vector2i.ZERO,
		canvas_image.get_size()
	)

	rect = rect.intersection(image_rect)

	if rect.size.x <= 0 or rect.size.y <= 0:
		return

	remaining_mask.set_bit_rect(rect, false)
	remaining_pixel_count = remaining_mask.get_true_bit_count()

	if (
		remaining_pixel_count < starting_pixel_count 
		and not mop.is_dirty
	):
		mop.get_dirty()

	canvas_image.fill_rect(rect, Color.TRANSPARENT)
	canvas_texture.update(canvas_image)


func initialize_progress_mask() -> void:
	remaining_mask = BitMap.new()
	remaining_mask.create_from_image_alpha(canvas_image, 0.0)

	starting_pixel_count = remaining_mask.get_true_bit_count()
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

	progress_label.text = "Erased: 100%"

	Events.emit_signal("minigame_end")
	Events.spill_clean_done.emit()
