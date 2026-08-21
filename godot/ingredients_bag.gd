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
	#if Global.holding_ingredients or already_interacted:
	#return
	ingredients_bag_taken.emit(self)
	Global.holding_ingredients = true
	already_interacted = true
	Events.play_viewmodel_animation.emit("bag_pickup")
	await Events.bag_pickup_animation_grabbed
	queue_free()
