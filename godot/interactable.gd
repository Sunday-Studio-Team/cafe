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
		if enabled:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
			time_held = 0
var time_held: float = 0


func _ready() -> void:
	interacted.connect(_on_interacted)

	enabled = visible
	visibility_changed.connect(
		func():
			enabled = visible
	)

	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)


func uses_timer_hold() -> bool:
	return true


func get_custom_hold_progress() -> float:
	if time_to_hold <= 0.0:
		return 0.0
	return clampf(time_held / time_to_hold, 0.0, 1.0)


func _process_custom_hold(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if (
		Global.hovered_interactable != self
		or not enabled
		or Global.in_pc_ui
		or Global.minigame_active
	):
		if mesh:
			mesh.material_overlay = null
		if not keep_progress_on_interrupt:
			time_held = 0.0
		return

	if Input.is_action_just_pressed("interact") and not hold_to_interact:
		interacted.emit()

	if Input.is_action_pressed("interact") and hold_to_interact:
		if uses_timer_hold():
			time_held += delta
			if time_held >= time_to_hold:
				interacted.emit()
				time_held = 0.0
		else:
			_process_custom_hold(delta)
	elif not keep_progress_on_interrupt:
		time_held = 0.0
	elif not uses_timer_hold():
		time_held = get_custom_hold_progress() * time_to_hold

	if mesh:
		mesh.material_overlay = ShaderMaterial.new()
		mesh.material_overlay.shader = Global.hover_shader


func _on_interacted() -> void:
	await get_tree().process_frame
	Global.hovered_interactable = null
