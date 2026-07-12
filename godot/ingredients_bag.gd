extends RigidBody3D

@export var interactable: Interactable


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

	# briefly disable on spawn so if we're dropping it we cant accidentally
	# interact with it as it falls
	interactable.enabled = false
	await get_tree().create_timer(0.5, false).timeout
	interactable.enabled = true


func _on_interacted() -> void:
	if Global.holding_ingredients:
		return
	Global.holding_ingredients = true
	queue_free()
