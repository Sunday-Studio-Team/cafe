class_name IngredientsBag
extends RigidBody3D

signal ingredients_bag_taken(ingredients_bag: IngredientsBag)

@export var interactable: Interactable
@export var default_model: MeshInstance3D
@export var large_model: MeshInstance3D

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

	Events.items_updated.connect(handle_xl_bag_item)
	handle_xl_bag_item()


func _physics_process(_delta: float) -> void:
	interactable.visible = (
			Global.shift_started and not Global.holding_ingredients and not already_interacted
	)


func handle_xl_bag_item() -> void:
	var has_xl_bag_item := false
	for item: Item in Global.owned_items:
		if item.item_id == "nice_spoon":
			has_xl_bag_item = true
			break

	if has_xl_bag_item:
		large_model.show()
		default_model.hide()
		interactable.mesh = large_model
	else:
		default_model.show()
		large_model.hide()
		interactable.mesh = default_model


func _on_interacted() -> void:
	Global.tutorial_ingredients_bag_got = true
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
