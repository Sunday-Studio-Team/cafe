class_name Teleporter
extends Area3D

@export var destination: Marker3D
@export var use_sound: AudioStreamPlayer


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	_enable_or_disable_based_on_if_we_have_the_item()
	Events.items_updated.connect(_enable_or_disable_based_on_if_we_have_the_item)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		use_sound.play()
		body.global_position = destination.global_position
		body.velocity = Vector3.ZERO
		body.reset_physics_interpolation()


func _enable_or_disable_based_on_if_we_have_the_item() -> void:
	var we_have_the_item := false

	if Global.owned_items.any(
			func(item: Item) -> bool:
			return item.item_id == "teleporter"
	):
		we_have_the_item = true

	if we_have_the_item:
		visible = true
		monitoring = true
	else:
		visible = false
		monitoring = false
