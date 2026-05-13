class_name Interactable
extends Area3D

# interact functionality can either be defined by extending this script
# and modifying _on_interacted(), or by connecting this signal to a function
# in another script
signal interacted

## the name that will show in UI for this interactable
@export var display_name: String
## enabled to make this interactable disable itself after interacting
@export var one_time_only := false
## how long this interactable should be disabled after interacting
## (if not onetimeonly)
@export var lockout_length: float = 1.0
## mesh used for this object
@export var mesh: MeshInstance3D

var enabled := true


func _ready() -> void:
	interacted.connect(_on_interacted)


func _physics_process(_delta: float) -> void:
	if Global.hovered_interactable != self or not enabled:
		mesh.material_overlay = null
		return

	mesh.material_overlay = ShaderMaterial.new()
	mesh.material_overlay.shader = Global.hover_shader

	if Input.is_action_just_pressed("interact"):
		interacted.emit()


# NOTE: all this lockout stuff is a bit untested tbh lol
# (also probably a more elegant way to do things than this)
func _on_interacted() -> void:
	Global.hovered_interactable = null
	enabled = false
	if not one_time_only:
		await get_tree().create_timer(lockout_length, false).timeout
		enabled = true
