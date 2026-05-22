class_name Interactable
extends Area3D
## NOTE: PUT INTERACTABLES ON PHYSICS LAYER 2 OR THEY WONT WORK

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
## how long the player has to hold to interact (if hold_to_interact is enabled)
@export var time_to_hold: float = 5

var enabled := true:
	set(value):
		enabled = value
		if enabled:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
var time_held: float = 0


func _ready() -> void:
	interacted.connect(_on_interacted)

	enabled = visible
	visibility_changed.connect(
		func():
			enabled = visible
	)


func _physics_process(delta: float) -> void:
	if Global.hovered_interactable != self or not enabled:
		if mesh:
			mesh.material_overlay = null
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
		time_held = 0

	if mesh:
		mesh.material_overlay = ShaderMaterial.new()
		mesh.material_overlay.shader = Global.hover_shader


func _on_interacted() -> void:
	Global.hovered_interactable = null
	enabled = false
