class_name CustomerTrash
extends RigidBody3D

@export var interactable: Interactable
@export var xray_material: Material
@export var trash_cup: MeshInstance3D
@export var activation_distance := 3.0
@export var trail: GPUParticles3D
@export var hint_pop: AnimatedSprite3D

signal trash_bag_taken(customer_trash: CustomerTrash)

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false
var time_left_out: float = 0.0
var cup_body_surface_index := 2
var threshold_velocity := 1
var being_slow := false
var hind_height_offset := 1.5

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

	# briefly disable on spawn so if we're dropping it we cant accidentally
	# interact with it as it falls
	interactable.visible = false
	await get_tree().create_timer(0.5, false).timeout
	interactable.visible = true
	
	hint_pop.animation_finished.connect(_on_pop_out_finished)
	hint_pop.play("Pop")
	hint_pop.top_level = true


func _process(_delta: float) -> void:
	var player: Player = Global.player

	if global_position.distance_to(player.global_position) <= activation_distance:
		trash_cup.set_surface_override_material(cup_body_surface_index, xray_material)
	else:
		trash_cup.set_surface_override_material(cup_body_surface_index, null)

	hint_pop.global_position = global_position + Vector3(0, hind_height_offset, 0)
	var speed := linear_velocity.length()
	if speed > threshold_velocity && trail.process_material != null:
		trail.emitting = true
		hint_pop.visible = false
		being_slow = false
	elif !being_slow:
		being_slow = true
		hint_pop.play("Pop")
		hint_pop.visible = true
		trail.emitting = false

func _on_interacted() -> void:
	if Global.holding_trash || already_interacted || Global.holding_ingredients:
		return

	trash_bag_taken.emit(self)
	Global.holding_trash = true
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
	
	await Events.trash_pickup_animation_grabbed
	queue_free()


func _on_pop_out_finished() -> void:
	hint_pop.play("Normal")
