class_name DraggableMop
extends Sprite2D

static var used_scrubber: bool = false

@export var bubbles: GPUParticles2D
@export var splash: AudioStreamPlayer2D
@export var mop_range: CollisionShape2D
@export var mop_texture: Texture
@export var wet_mop_texture: Texture
@export var dirty_mop_texture: Texture
@export var scrubber_texture: Texture
@export var wet_scrubber_texture: Texture
@export var dirty_scrubber_texture: Texture


var drag_offset: Vector2 = Vector2.ZERO
var is_wet: bool = false
var is_dirty: bool = false

@onready var mop_start_position: Vector2 = position


func _ready() -> void:
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
		mop_range.shape.size.x = scrubber_texture.get_width()
		
		scale *= 1.5
	else:
		texture = mop_texture


func _physics_process(_delta: float) -> void:
	global_position = (get_global_mouse_position() + drag_offset)
	reset_physics_interpolation()


func _exit_tree() -> void:
	Global.in_spill_minigame = false


func wet_mop() -> void:
	if not is_wet:
		splash.play()
		is_wet = true
		bubbles.emitting = true
		if used_scrubber:
			texture = wet_scrubber_texture
		else:
			texture = wet_mop_texture


func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = (event as InputEventMouseButton)

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return


func get_dirty() -> void:
	if is_dirty:
		return

	is_dirty = true

	if used_scrubber:
		texture = dirty_scrubber_texture
	else:
		texture = dirty_mop_texture
