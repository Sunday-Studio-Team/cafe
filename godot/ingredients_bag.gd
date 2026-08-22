class_name IngredientsBag
extends RigidBody3D

signal ingredients_bag_taken(ingredients_bag: IngredientsBag)

@export var interactable: Interactable

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func _physics_process(_delta: float) -> void:
	interactable.visible = (
		Global.shift_started and not Global.holding_ingredients and not already_interacted
	)


func _on_interacted() -> void:
	ingredients_bag_taken.emit(self)
	Global.holding_ingredients = true
	already_interacted = true
	Events.play_viewmodel_animation.emit("bag_pickup")

	# basically some weird stuff can happen if we throw the bag right after we
	# pick up, so we just get rid of it if something weird happened which
	# caused it to still be in the tree after a while
	var timer_to_delete_if_something_went_wrong := Timer.new()
	timer_to_delete_if_something_went_wrong.wait_time = 0.25
	timer_to_delete_if_something_went_wrong.timeout.connect(
		func():
			await create_tween().tween_property(self, "scale", Vector3.ZERO, 0.1).finished
			queue_free(),
	)
	add_child(timer_to_delete_if_something_went_wrong)
	timer_to_delete_if_something_went_wrong.start()

	# then this is just what should normally happen (we delete the bag when the
	# part of the animation that looks like we're grabbing it plays)
	await Events.bag_pickup_animation_grabbed
	queue_free()
