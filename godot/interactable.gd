class_name Interactable
extends Area3D

# interact functionality can either be defined by extending this script
# and modifying _on_interacted(), or by connecting this signal to a function
# in another script
signal interacted
# this is like the interacted signal but it gets emitted when we pres Q instead of E .
signal requested_use_active_item

# For checking unique interactables
@export var interactable_id: StringName
## the name that will show in UI for this interactable
@export var display_name: String
## mesh used for this object
@export var mesh: MeshInstance3D
@export var show_interact_hotkey: bool = true


func _init() -> void:
	interacted.connect(_on_interacted)

	_update_enabled()
	visibility_changed.connect(_on_visibility_changed)

	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)


func _physics_process(_delta: float) -> void:
	_update_material()

	if (
		Global.hovered_interactable != self
		or not visible
		or Global.in_pc_ui
		or Global.minigame_active
		or Global.camera_mode != Global.CameraMode.PLAYER
	):
		return

	if show_interact_hotkey:
		if Input.is_action_just_pressed("interact"):
			interacted.emit()

	# alt interaction where player uses an item on this interactable
	if Input.is_action_just_pressed("use_item"):
		requested_use_active_item.emit()


func _on_visibility_changed() -> void:
	_update_enabled()


func _update_enabled() -> void:
	_update_material()
	if visible:
		process_mode = ProcessMode.PROCESS_MODE_INHERIT
	else:
		process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _on_interacted() -> void:
	await get_tree().process_frame
	Global.hovered_interactable = null


func _update_material() -> void:
	if (
		Global.hovered_interactable != self or not visible
		or Global.in_pc_ui or Global.minigame_active
	):
		if mesh:
			mesh.material_overlay = null
		return

	if mesh:
		mesh.material_overlay = ShaderMaterial.new()
		mesh.material_overlay.shader = Global.hover_shader
