extends Node2D

@export var eraser_radius: int = 30
@export var canvas_sprite: Sprite2D
@export var progress_label: Label
# 0.0 means every visible pixel must be erased.
# You could use 0.01 to allow 1% of the image to remain.
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio: float = 0.01
@export_range(0.25, 1.0, 0.05)
var brush_spacing_ratio: float = 0.5



# If a pixel has alpha value lower then the threshold,
# it was consider transparent
const ALPHA_THRESHOLD_BYTE: int = 5


var canvas_image: Image
var canvas_texture: ImageTexture
var starting_pixel_count: int = 0
var remaining_pixel_count: int = 0

var image_width: int
var image_height: int
var pixel_data: PackedByteArray
var brush_offsets: Array[Vector2i] = []

var is_erasing: bool = false
var has_previous_position: bool = false
var previous_pixel_position: Vector2i
var game_finished: bool = false


func _ready() -> void:
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

	create_brush_offsets()
	count_starting_pixels()
	update_progress_display()


func _input(event: InputEvent) -> void:
	if game_finished:
		return

	# Start or stop erasing when the left mouse button changes.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_erasing = event.pressed
			has_previous_position = false


func _physics_process(_delta: float) -> void:
	if game_finished or not is_erasing:
		return

	var current_position: Vector2i = get_mouse_image_position()

	if current_position.x < 0:
		has_previous_position = false
		return

	if (
		has_previous_position 
		and current_position == previous_pixel_position
	):
		return

	var image_changed: bool

	image_changed = erase_circle(current_position)

	previous_pixel_position = current_position
	has_previous_position = true
 
	if not image_changed:
		return

	upload_changed_image()
	update_progress_display()
	check_for_win()


func create_brush_offsets() -> void:
	brush_offsets.clear()

	var radius_squared: int = eraser_radius * eraser_radius

	for offset_y: int in range(-eraser_radius, eraser_radius + 1):
		for offset_x: int in range(-eraser_radius, eraser_radius + 1):
			var distance_squared: int = (
				offset_x * offset_x + offset_y * offset_y)

			if distance_squared <= radius_squared:
				brush_offsets.append(Vector2i(offset_x, offset_y))


func erase_at_mouse() -> void:
	var current_position: Vector2i = get_mouse_image_position()

	# Negative values mean that the mouse is outside the canvas.
	if current_position.x < 0:
		has_previous_position = false
		return

	erase_circle(current_position)

	previous_pixel_position = current_position
	has_previous_position = true
	canvas_texture.update(canvas_image)

	update_progress_display()
	check_for_win()


func get_mouse_image_position() -> Vector2i:
	# Mouse position relative to ErasableCanvas.
	var local_mouse_position: Vector2 
	local_mouse_position = canvas_sprite.get_local_mouse_position()

	# Rectangle occupied by the sprite in its local coordinate system.
	var sprite_rect: Rect2 = canvas_sprite.get_rect()

	# Check if the mouse is in the canvas, return (-1, -1) if it isn't
	if not sprite_rect.has_point(local_mouse_position):
		return Vector2i(-1, -1)

	# Convert the mouse position into a value from 0 to 1.
	var normalized_position: Vector2 = (
			(local_mouse_position - sprite_rect.position)
			/ sprite_rect.size
	)

	# Convert the normalized position into image-pixel coordinates.
	var pixel_x: int = int(normalized_position.x * image_width)
	var pixel_y: int = int(normalized_position.y * image_height)

	# Clamp the coordinate if it is out of the boundary
	pixel_x = clampi(pixel_x, 0, image_width - 1)
	pixel_y = clampi(pixel_y, 0, image_height - 1)

	return Vector2i(pixel_x, pixel_y)


func erase_circle(center: Vector2i) -> bool:
	var image_changed: bool = false

	for offset: Vector2i in brush_offsets:
		var x: int = center.x + offset.x
		var y: int = center.y + offset.y

		if (
			x < 0
			or x >= image_width
			or y < 0
			or y >= image_height
		):
			continue

		var pixel_number: int = y * image_width + x
		# The fourth RGBA8 byte is alpha, adding 3 to access it.
		var alpha_index: int = pixel_number * 4 + 3

		if pixel_data[alpha_index] > ALPHA_THRESHOLD_BYTE:
			pixel_data[alpha_index] = 0
			remaining_pixel_count -= 1
			image_changed = true
	
	return image_changed


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
	if starting_pixel_count <= allowed_remaining_ratio:
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
