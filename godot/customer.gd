class_name Customer
extends Node3D

# NOTE: maybe im dumb but seems weird that this has an argument since this isnt
# a global signal - whatevers connecting to this signal should already be able
# to see which customer it is right ? i'll investigate tho .
signal wait_timed_out(customer: Customer)

const MOVE_SPEED := 2.0

@export var full_body_sprite: Sprite3D
## the indicator is the whole ui element including the little ⌛ icon
@export var waiting_indicator: Sprite3D
## the bar is literally just the bar thing (its more like a circle thing than a bar tho)
@export var waiting_bar: TextureProgressBar
@export var timer: Timer
@export var time_bonus_label: Label3D
@export var spawn_sound: AudioStreamPlayer3D

@export_dir var sprites_folder: String
@export_dir var typing_minigame_portraits_folder: String

var customer_sprite_resource: CustomerSpriteData:
	set(new):
		customer_sprite_resource = new
		# we still need to do this even tho we're using an override cos this
		# texture decides the size of the sprite (we'll get stretching otherwise)
		full_body_sprite.texture = new.sprite
		override_material.albedo_texture = new.sprite
		Global.customer_sprites_in_use.append(customer_sprite_resource)
var desired_drink: Drink
var orders_made: int = 0
var at_window: bool = false
var percent_time_left: float = 100
var _total_wait_time: float

@onready var override_material: StandardMaterial3D = full_body_sprite.material_override.duplicate()


func _ready() -> void:
	# we use an override material to get rim lighting n stuff
	full_body_sprite.material_override = override_material
	
	# Find all unused customer sprites
	var unused_customer_sprites: Array[CustomerSpriteData]
	for customer_sprite in Global.customer_sprites:
		if !Global.customer_sprites_in_use.has(customer_sprite):
			unused_customer_sprites.append(customer_sprite)

	# Prefer using an unused one, else just get a random one.
	if unused_customer_sprites.size() > 0:
		customer_sprite_resource = unused_customer_sprites.pick_random()
	else:
		customer_sprite_resource = Global.customer_sprites.pick_random()

	get_stats()
	timer.timeout.connect(_on_timer_timeout)
	Events.customer_started_order.connect(_on_order_started)
	Events.order_served.connect(_on_order_served)
	# NOTE: not actually sure what this true argument does here lol
	# NOTE^2: it keeps the customers group tag if the packed scene file is saved
	# NOTE^3: ok thx
	# NOTE^4: actually tbh i dont get it why how would it apply to a saved file
	# when it only runs in _ready()
	add_to_group("customers", true)

	desired_drink = Global.drinks.filter(
		func(d: Drink):
			return d.is_unlocked(),
	).pick_random()

	spawn_anim()
	spawn_sound.play()


func _physics_process(_delta: float) -> void:
	# uncomment to show time above customer head
	# NOTE: i think the help desk might manually show this indicator
	# waiting_indicator.visible = not timer.is_stopped()
	
	if not waiting_indicator.visible:
		return
	
	if not timer.is_stopped():
		percent_time_left = timer.time_left / timer.wait_time * 100
		if timer.wait_time == INF:
			percent_time_left = 100

	if percent_time_left >= 66:
		waiting_indicator.modulate = Color.GREEN
	elif percent_time_left >= 33:
		waiting_indicator.modulate = Color.ORANGE
	else:
		waiting_indicator.modulate = Color.RED

	waiting_bar.value = percent_time_left


func _exit_tree() -> void:
	Global.customer_sprites_in_use.erase(customer_sprite_resource)


func spawn_anim() -> void:
	const DUR := 0.25

	var t := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	t.tween_property(full_body_sprite, "transparency", 0, DUR).from(1)
	t.tween_property(full_body_sprite, "scale:y", 1, DUR).from(1.25)


func despawn_anim() -> void:
	const DUR := 0.25

	var t := create_tween().set_parallel().set_ease(Tween.EASE_IN)
	t.tween_property(full_body_sprite, "transparency", 1, DUR).from(0)
	t.tween_property(full_body_sprite, "scale:y", 1.25, DUR).from(1)

	await t.finished


# smoothly move to a location
# NOTE: loc should be a global position
func move_to(loc: Vector3) -> void:
	var dur := global_position.distance_to(loc) / MOVE_SPEED

	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", loc, dur)
	await t.finished


func extend_wait_patience_time(duration: float) -> void:
	_total_wait_time += duration
	if timer.time_left > 0:
		timer.start(timer.time_left + duration)


func get_stats():
	_total_wait_time = Stats.current.customer_wait_time_machine_each_day[Global.day]
	timer.wait_time = _total_wait_time


func leave_store() -> void:
	waiting_indicator.hide()
	await move_to(Global.customer_leaving_spot.global_position)
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	spawn_sound.pitch_scale = 4
	spawn_sound.play()
	await despawn_anim()
	queue_free()
	Events.customer_leave.emit()


func _on_timer_timeout() -> void:
	wait_timed_out.emit(self)


func _on_order_started(customer: Customer) -> void:
	if customer != self or orders_made > 0:
		return
	await get_tree().process_frame
	
	# Don't start the timer if playing tutorial!
	if not Global.playing_tutorial:
		timer.start()
	
	orders_made += 1


func _on_order_served(customer: Customer) -> void:
	if customer != self:
		return

	timer.stop()
