extends Node2D


@export var eraser_radius: int = 30

# 0.0 means every visible pixel must be erased.
# You could use 0.01 to allow 1% of the image to remain.
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio: float = Stats.current.clean_spill_allowed_remaining
@export var canvas_sprite: Sprite2D
@export var progress_label: Label
@export_dir var canvas_folder: String = \
	"res://minigames/spill_clean/stains"


var canvas_image: Image
var canvas_texture: ImageTexture

var starting_pixel_count: int = 0
var remaining_pixel_count: int = 0

var is_erasing: bool = false
var has_previous_position: bool = false
var previous_pixel_position: Vector2i

var game_finished: bool = false


func _ready() -> void:
	# Choose the image before creating the editable Image.
	if not choose_random_canvas():
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Create an editable copy of the randomly selected image.
	canvas_image = canvas_sprite.texture.get_image()

	canvas_image.convert(Image.FORMAT_RGBA8)

	canvas_texture = ImageTexture.create_from_image(
		canvas_image
	)

	canvas_sprite.texture = canvas_texture

	count_starting_pixels()

	update_progress_display()

	
func _input(event: InputEvent) -> void:
	if game_finished:
		return

	# Start or stop erasing when the left mouse button changes.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_erasing = event.pressed

			if is_erasing:
				has_previous_position = false
				erase_at_mouse()

			else:
				has_previous_position = false

	# Continue erasing while the mouse moves.
	elif event is InputEventMouseMotion:
		if is_erasing:
			erase_at_mouse()


func erase_at_mouse() -> void:
	var current_position: Vector2i = get_mouse_image_position()

	# Negative values mean that the mouse is outside the canvas.
	if current_position.x < 0:
		has_previous_position = false
		return

	if has_previous_position:
		erase_between_points(previous_pixel_position, current_position)
	else:
		erase_circle(current_position)

	previous_pixel_position = current_position
	has_previous_position = true
	canvas_texture.update(canvas_image)

	update_progress_display()
	check_for_win()
	
	
func choose_random_canvas() -> bool:
	var canvas_paths: Array[String] = []

	for file_name: String in ResourceLoader.list_directory(canvas_folder):
		if file_name.get_extension().to_lower() == "png":
			var full_path: String = canvas_folder.path_join(file_name)

			canvas_paths.append(full_path)

	# Prevent an error if no PNG images were found.
	if canvas_paths.is_empty():
		push_error(
			"No PNG files were found in: "
			+ canvas_folder
		)

		return false

	var selected_path: String = canvas_paths.pick_random()

	var selected_texture: Texture2D = (
		load(selected_path) as Texture2D
	)

	if selected_texture == null:
		push_error(
			"Failed to load: "
			+ selected_path
		)

		return false

	canvas_sprite.texture = selected_texture

	print(
		"Selected canvas: ",
		selected_path
	)

	return true


func get_mouse_image_position() -> Vector2i:
	# Mouse position relative to ErasableCanvas.
	var local_mouse_position: Vector2 = canvas_sprite.get_local_mouse_position()

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
	var pixel_x: int = int(
		normalized_position.x * canvas_image.get_width()
	)
	var pixel_y: int = int(
		normalized_position.y * canvas_image.get_height()
	)

	# Clamp the coordinate if it is out of the boundary
	pixel_x = clampi(pixel_x, 0, canvas_image.get_width() - 1)
	pixel_y = clampi(pixel_y, 0, canvas_image.get_height() - 1)

	return Vector2i(pixel_x, pixel_y)


func erase_between_points(
	start_position: Vector2i,
	end_position: Vector2i
) -> void:

	var start: Vector2 = Vector2(start_position)
	var end: Vector2 = Vector2(end_position)

	var distance: float = start.distance_to(end)

	var spacing: float = eraser_radius * 0.25

	var number_of_steps: int = max(
		1,
		ceili(distance / spacing)
	)

	for step: int in range(number_of_steps + 1):
		var interpolation_amount: float = (
			float(step)
			/ float(number_of_steps)
		)

		var erase_position: Vector2 = start.lerp(
			end,
			interpolation_amount
		)

		erase_circle(Vector2i(erase_position))


func erase_circle(center: Vector2i) -> void:
	var minimum_x: int = max(
		0,
		center.x - eraser_radius
	)

	var maximum_x: int = min(
		canvas_image.get_width() - 1,
		center.x + eraser_radius
	)

	var minimum_y: int = max(
		0,
		center.y - eraser_radius
	)

	var maximum_y: int = min(
		canvas_image.get_height() - 1,
		center.y + eraser_radius
	)

	var radius_squared: int = (
		eraser_radius
		* eraser_radius
	)

	for y: int in range(minimum_y, maximum_y + 1):
		for x: int in range(minimum_x, maximum_x + 1):
			var difference_x: int = x - center.x
			var difference_y: int = y - center.y

			var distance_squared: int = (
				difference_x * difference_x 
				+ difference_y * difference_y)

			# Taking the sqrt does not affect the order relationship.
			# Ignore pixels outside the circular eraser.
			if distance_squared > radius_squared:
				continue

			var pixel_color: Color = (canvas_image.get_pixel(x, y))

			# Only count the pixel again if it has not already been erased.
			if pixel_color.a > 0.01:
				pixel_color.a = 0.0

				canvas_image.set_pixel(
					x,
					y,
					pixel_color
				)

				remaining_pixel_count -= 1


func count_starting_pixels() -> void:
	starting_pixel_count = 0

	for y: int in range(canvas_image.get_height()):
		for x: int in range(canvas_image.get_width()):
			var pixel_color: Color = (canvas_image.get_pixel(x, y))

			if pixel_color.a > 0.01:
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
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	progress_label.text = "Erased: 100%"

	Events.emit_signal("minigame_end")
