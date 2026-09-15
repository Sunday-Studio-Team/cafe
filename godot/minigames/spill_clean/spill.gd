class_name ErasableCanvas
extends Node2D


@export var canvas_sprite: Sprite2D
@export var canvas_sprite2: Sprite2D
@export var canvas_sprite3: Sprite2D

#@export var progress_label: Label
@export var moping_area: Area2D
@export var bucket: Sprite2D
@export var machine_clean: Sprite2D
@export var machine_dirty: Sprite2D
@export var bucket_area: Area2D
@export var mop: DraggableMop
@export var text_bubble: TippyText



# 0.0 means every visible pixel must be erased.
# You could use 0.01 to allow 1% of the image to remain.
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio: float # = Stats.current.clean_spill_allowed_remaining
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio2: float
@export_range(0.00, 1.0, 0.001)
var allowed_remaining_ratio3: float
@export_range(0.00, 1.0, 0.001)
var machine_clean_ratio: float
@export_range(0.00, 1.0, 0.001)
var spill_clean_speed: float
var mop_collision: CollisionShape2D
var mop_rectangle: RectangleShape2D
var canvas_image: Image
var canvas_texture: ImageTexture
#var starting_pixel_count: int = 0
#var remaining_pixel_count: int = 0
var starting_scale: Vector2 = Vector2(1.0, 1.0)
var current_scale: Vector2 = Vector2(1.0, 1.0)
var current_spill: int = 0
var new_scale: Vector2 = Vector2(1.0, 1.0)
var image_width: int
var image_height: int
var game_finished: bool = false
var previous_mop_position := Vector2.INF
var remaining_mask: BitMap
var remaining_ratio: float:
	get():
		return new_scale.x / starting_scale.x


func _ready() -> void:
	Global.minigame_active = true
	Global.in_spill_minigame = true
	#canvas_sprite.texture = Global.spill_sprites.pick_random()

	canvas_image = canvas_sprite.texture.get_image()
	canvas_image.convert(Image.FORMAT_RGBA8)
	canvas_image.clear_mipmaps()

	image_width = canvas_image.get_width()
	image_height = canvas_image.get_height()

	canvas_texture = ImageTexture.create_from_image(canvas_image)
	canvas_sprite.texture = canvas_texture

	canvas_sprite2.visible = false
	canvas_sprite3.visible = false

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
			if _area == moping_area && not mop.is_wet:
				mop.wet_mop()
				text_bubble.mop_entered()
	)

	#initialize_progress_mask()
	#update_progress_display()


func _physics_process(_delta: float) -> void:
	if game_finished or not mop.is_wet:
		return

	if mop_collision == null or mop_collision.disabled:
		return
	
	if mop_collision.global_position.distance_to(previous_mop_position) < 50.0:
		return

	var rect: Rect2i = erased_area_inside_mop_rectangle()
	
	previous_mop_position = mop_collision.global_position

	check_machine_clean()
	update_image(rect)
	#update_progress_display()
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

	#remaining_mask.set_bit_rect(rect, false)
	#remaining_pixel_count = remaining_mask.get_true_bit_count()
	

	if current_spill == 0:
		current_scale = canvas_sprite.scale
		new_scale = Vector2(current_scale.x - spill_clean_speed, current_scale.y - spill_clean_speed)	
		print("new scale spill 0", new_scale)

		if (
			new_scale < current_scale
			and not mop.is_dirty
		):
			mop.get_dirty()
		
		canvas_sprite.scale = new_scale
	elif current_spill == 1:
		current_scale = canvas_sprite2.scale
		new_scale = Vector2(current_scale.x - spill_clean_speed, current_scale.y - spill_clean_speed)	
		print("new scale spill 1", new_scale)

		if (
			new_scale < current_scale
			and not mop.is_dirty
		):
			mop.get_dirty()
		
		canvas_sprite2.scale = new_scale
	elif current_spill == 2:
		current_scale = canvas_sprite3.scale
		new_scale = Vector2(current_scale.x - spill_clean_speed, current_scale.y - spill_clean_speed)	
		print("new scale spill 2", new_scale)

		if (
			new_scale < current_scale
			and not mop.is_dirty
		):
			mop.get_dirty()
		
		canvas_sprite3.scale = new_scale
		
#func initialize_progress_mask() -> void:
	#remaining_mask = BitMap.new()
	#remaining_mask.create_from_image_alpha(canvas_image, 0.0)

	#starting_pixel_count = remaining_mask.get_true_bit_count()
	#remaining_pixel_count = starting_pixel_count


#func update_progress_display() -> void:
	#if starting_pixel_count <= 0:
		#progress_label.text = "Erased: 100%"
		#return
#
	#var erased_ratio: float = 1.0 - remaining_ratio
#
	#var erased_percentage: int = roundi(erased_ratio * 100.0)
#
	#progress_label.text = ("Erased: %d%%" % erased_percentage)

func check_machine_clean() -> void:
	if remaining_ratio <= machine_clean_ratio and current_spill == 2:
		machine_clean.visible = true
		machine_dirty.visible = false
	else:
		machine_clean.visible = false
		machine_dirty.visible = true

func check_for_win() -> void:
	#if starting_pixel_count <= 0:
		#win_game()
		#return
	print("remaining_ratio", remaining_ratio)
	
	if remaining_ratio <= allowed_remaining_ratio and current_spill == 0:
		canvas_sprite.visible = false
		canvas_sprite2.visible = true
		canvas_image = canvas_sprite2.texture.get_image()
		canvas_image.convert(Image.FORMAT_RGBA8)
		canvas_image.clear_mipmaps()

		image_width = canvas_image.get_width()
		image_height = canvas_image.get_height()

		canvas_texture = ImageTexture.create_from_image(canvas_image)
		canvas_sprite2.texture = canvas_texture
		current_spill = 1
		
		#reset params here
		starting_scale = Vector2(1.0, 1.0)
		current_scale = Vector2(1.0, 1.0)
		new_scale = Vector2(1.0, 1.0)
		print("moving to second spill")
		
	elif remaining_ratio <= allowed_remaining_ratio2 and current_spill == 1:
		canvas_sprite2.visible = false
		canvas_sprite3.visible = true
		canvas_image = canvas_sprite3.texture.get_image()
		canvas_image.convert(Image.FORMAT_RGBA8)
		canvas_image.clear_mipmaps()

		image_width = canvas_image.get_width()
		image_height = canvas_image.get_height()

		canvas_texture = ImageTexture.create_from_image(canvas_image)
		canvas_sprite3.texture = canvas_texture
		current_spill = 2

		#reset params here
		starting_scale = Vector2(1.0, 1.0)
		current_scale = Vector2(1.0, 1.0)
		new_scale = Vector2(1.0, 1.0)
		print("moving to final spill")
		
	elif remaining_ratio <= allowed_remaining_ratio3 and current_spill == 2:
		win_game()


func win_game() -> void:
	if game_finished:
		return

	game_finished = true

	#progress_label.text = "Erased: 100%"

	Events.emit_signal("minigame_end")
	Events.spill_clean_done.emit()
