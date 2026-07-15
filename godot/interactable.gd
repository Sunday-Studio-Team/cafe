class_name Interactable
extends Area3D

# interact functionality can either be defined by extending this script
# and modifying _on_interacted(), or by connecting this signal to a function
# in another script
signal interacted

## the name that will show in UI for this interactable
@export var display_name: String
## mesh used for this object
@export var mesh: MeshInstance3D
## if enabled, player has to HOLD interact to interact with this
## (if disabled, they just have to press once)
@export var hold_to_interact: bool = false
## if enabled, the interact progress bar won't reset if we stop interacting
@export var keep_progress_on_interrupt: bool = false
## how long the player has to hold to interact (if hold_to_interact is enabled)
@export var time_to_hold: float = 6

var enabled := true:
	set(value):
		enabled = value
		_update_material()
		if enabled:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
			time_held = 0
var time_held: float = 0


func _init() -> void:
	interacted.connect(_on_interacted)

	enabled = visible
	visibility_changed.connect(
		func():
			enabled = visible
	)

	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)


func _process(delta: float) -> void:
	_update_material()
	
	if (
		Global.hovered_interactable != self
		or not enabled
		or Global.in_pc_ui
		or Global.minigame_active
	):
		if not keep_progress_on_interrupt:
			time_held = 0
		return

	# One time press
	if Input.is_action_just_pressed("interact") and not hold_to_interact:
		interacted.emit()

	# Hold to press
	if Input.is_action_pressed("interact") and hold_to_interact:
		time_held += delta
		if time_held >= time_to_hold:
			interacted.emit()
			time_held = 0
	else:
		if not keep_progress_on_interrupt:
			time_held = 0


func _on_interacted() -> void:
	await get_tree().process_frame
	Global.hovered_interactable = null

func _update_material() -> void:
	if (Global.hovered_interactable != self
		or not enabled
		or Global.in_pc_ui
		or Global.minigame_active
	):
		if mesh:
			mesh.material_overlay = null
		return


	if mesh:
		mesh.material_overlay = ShaderMaterial.new()
		mesh.material_overlay.shader = Global.hover_shader
