class_name DraggableMop
extends Sprite2D

@export_category("Nodes")
@export var bubble_particles: GPUParticles2D
@export var splash_sound: AudioStreamPlayer2D
@export var mop_range: CollisionShape2D
@export_category("Assets")
## "normal" mop as opposed to the scrubber
@export var normal_mop_texture: Texture
@export var wet_mop_texture: Texture
@export var dirty_mop_texture: Texture
@export var scrubber_texture: Texture
@export var wet_scrubber_texture: Texture
@export var dirty_scrubber_texture: Texture

var player_has_super_scrubber_item: bool = false
var is_wet: bool = false
var is_dirty: bool = false

@onready var mop_start_position: Vector2 = position


func _ready() -> void:
	bubble_particles.emitting = false
	is_wet = false
	is_dirty = false

	for item in Global.owned_items:
		if item.item_id == "super_scrubber":
			player_has_super_scrubber_item = true
			break
	if player_has_super_scrubber_item:
		texture = scrubber_texture
		mop_range.shape.size.x = scrubber_texture.get_width()
		scale *= 1.5
	else:
		texture = normal_mop_texture


func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	reset_physics_interpolation()


# TODO: move this somewhere a bit nicer
func _exit_tree() -> void:
	Global.in_spill_minigame = false


func wet_mop() -> void:
	splash_sound.play()

	if not is_wet:
		is_wet = true
	is_dirty = false

	bubble_particles.emitting = true
	if player_has_super_scrubber_item:
		texture = wet_scrubber_texture
	else:
		texture = wet_mop_texture


func get_dirty() -> void:
	if is_dirty:
		return

	is_dirty = true

	if player_has_super_scrubber_item:
		texture = dirty_scrubber_texture
	else:
		texture = dirty_mop_texture
