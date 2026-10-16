class_name CustomerTrash
extends RigidBody3D

@export var interactable: Interactable
@export var xray_material: Material
@export var trash_cup: MeshInstance3D
@export var activation_distance := 3.0
@export var trail: GPUParticles3D
@export var hint_pop_animated_sprite_3d: AnimatedSprite3D
@export var hint_pop_sprite_frames_uid: StringName

signal trash_bag_taken(customer_trash: CustomerTrash)

var load_token: ResourceBackgroundLoaderToken
var hint_pop_animated_sprite_3d_ready: bool
var _hint_pop_animated_sprite_3d_relative_position: Vector3

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false
var time_left_out: float = 0.0
var cup_body_surface_index := 2
var threshold_velocity := 1
var being_slow := false

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)

	_hint_pop_animated_sprite_3d_relative_position = hint_pop_animated_sprite_3d.global_position - global_position
	
	# briefly disable on spawn so if we're dropping it we cant accidentally
	# interact with it as it falls
	interactable.visible = false
	await get_tree().create_timer(0.5, false).timeout
	interactable.visible = true

	hint_pop_animated_sprite_3d.visible = false
	load_token = Global.resource_background_loader.cache_resource(hint_pop_sprite_frames_uid)
	while !load_token.is_loaded:
		await get_tree().process_frame
	var sprite_frames: SpriteFrames =  Global.resource_background_loader.get_resource(load_token) as SpriteFrames
	if sprite_frames == null:
		printerr("CustomerTrash sprite_frames null!")
		return
	Global.resource_background_loader.uncache_resource(load_token)
	hint_pop_animated_sprite_3d.sprite_frames = sprite_frames
	hint_pop_animated_sprite_3d.visible = true
	
	hint_pop_animated_sprite_3d.animation_finished.connect(_on_pop_out_finished)
	hint_pop_animated_sprite_3d.play("Pop")
	hint_pop_animated_sprite_3d.top_level = true
	hint_pop_animated_sprite_3d_ready = true

func _exit_tree() -> void:
	# Unload just in case!
	Global.resource_background_loader.uncache_resource(load_token)

func _physics_process(delta: float) -> void:
	var player: Player = Global.player

	if global_position.distance_to(player.global_position) <= activation_distance:
		trash_cup.set_surface_override_material(cup_body_surface_index, xray_material)
	else:
		trash_cup.set_surface_override_material(cup_body_surface_index, null)

	var speed := linear_velocity.length()
	if speed > threshold_velocity && trail.process_material != null:
		trail.emitting = true
		being_slow = false
		if hint_pop_animated_sprite_3d_ready:
			hint_pop_animated_sprite_3d.visible = false
	elif !being_slow:
		being_slow = true
		trail.emitting = false
		if hint_pop_animated_sprite_3d_ready:
			hint_pop_animated_sprite_3d.play("Pop")
			hint_pop_animated_sprite_3d.visible = true

	hint_pop_animated_sprite_3d.global_position = global_position + _hint_pop_animated_sprite_3d_relative_position
	hint_pop_animated_sprite_3d.global_rotation = Vector3.ZERO

func _on_interacted() -> void:
	if Global.holding_trash || already_interacted || Global.holding_ingredients:
		return

	trash_bag_taken.emit(self)
	Global.holding_trash = true
	already_interacted = true
	Events.play_viewmodel_animation.emit("bag_pickup")

	Global.tutorial_day_4_trash_picked_up = true
	
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
	Global.resource_background_loader.uncache_resource(load_token)
	queue_free()


func _on_pop_out_finished() -> void:
	hint_pop_animated_sprite_3d.play("Normal")
