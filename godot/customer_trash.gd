class_name CustomerTrash
extends Area3D

@export var interactable: Interactable

signal trash_bag_taken(customer_trash: CustomerTrash)

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

	# briefly disable on spawn so if we're dropping it we cant accidentally
	# interact with it as it falls
	interactable.visible = false
	await get_tree().create_timer(0.5, false).timeout
	interactable.visible = true

func _on_interacted() -> void:
	if Global.holding_ingredients or already_interacted:
		return

	trash_bag_taken.emit(self)
	
	already_interacted = true
	Events.play_viewmodel_animation.emit("bag_pickup")
	await Events.trash_pickup_animation_grabbed
	Global.holding_ingredients = true
	queue_free()
