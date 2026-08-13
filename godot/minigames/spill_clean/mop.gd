class_name DraggableMop
extends Sprite2D

static var used_scrubber: bool = false

@export var drag_area: Area2D
@export var bubbles: GPUParticles2D
@export var splash: AudioStreamPlayer2D
@export var mope_range: CollisionShape2D
@export var mop_texture: Texture
@export var dirty_mop_texture: Texture
@export var scrubber_texture: Texture
@export var dirty_scrubber_texture: Texture

var drag_collision: CollisionShape2D
var drag_rectangle: RectangleShape2D
var drag_offset: Vector2 = Vector2.ZERO
var is_wet: bool = false
var is_dirty: bool = false
var normal_range = Vector2(644, 312)
var normal_offset = Vector2(16.0, -503.0)
var scrubber_range = Vector2(644.0, 1348.0)
var scrubber_offset = Vector2(0.0, -865.0)

@onready var mop_start_position: Vector2 = position


func _ready() -> void:
	if drag_area == null:
		push_error("Drag Area has not been assigned.")
		set_process(false)
		set_process_input(false)
		return

	if drag_area.get_child_count() == 0:
		push_error("Drag Area requires a CollisionShape2D child.")
		set_process(false)
		set_process_input(false)
		return

	drag_collision = (drag_area.get_child(0) as CollisionShape2D)

	if drag_collision == null:
		push_error("Drag Area's child must be a CollisionShape2D.")
		set_process(false)
		set_process_input(false)
		return

	drag_rectangle = (drag_collision.shape as RectangleShape2D)

	if drag_rectangle == null:
		push_error("The CollisionShape2D must use RectangleShape2D.")
		set_process(false)
		set_process_input(false)
		return

	if bubbles == null:
		push_error("Particle has not been assigned.")
		set_process(false)
		set_process_input(false)
		return

	bubbles.emitting = false
	is_wet = false
	is_dirty = false
	
	if used_scrubber:
		texture = scrubber_texture
		mope_range.position = scrubber_offset
		mope_range.shape.size = scrubber_range
	else:
		texture = mop_texture
		mope_range.position = normal_offset
		mope_range.shape.size = normal_range

func _process(_delta: float) -> void:
	global_position = (
			get_global_mouse_position()
			+ drag_offset
	)


func _exit_tree() -> void:
	Global.in_spill_minigame = false


func wet_mop() -> void:
	if not is_wet:
		splash.play()
		is_wet = true
		bubbles.emitting = true
		create_tween().tween_property(
			self,
			"modulate",
			Color.WHITE,
			1,
		).from(Color.AQUA)


func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = (
			event as InputEventMouseButton
	)

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
