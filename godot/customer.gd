class_name Customer
extends Node3D

signal wait_timed_out(customer: Customer)

const MOVE_SPEED := 2.0

@export var body: Sprite3D
@export var waiting_indicator: Sprite3D
@export var waiting_bar: TextureProgressBar
@export var timer: Timer
@export var time_bonus_label: Label3D
@export var spawn_sound: AudioStreamPlayer3D

@export_dir var sprites_folder: String
@export_dir var typing_minigame_portraits_folder: String

var customer_sprite_resource:CustomerSprite
var desired_drink: Drink
var orders_made: int = 0
var bonus_points_for_time: int
var at_window: bool = false
var _total_wait_time: float
var percent_time_left: float = 100


func _ready() -> void:
	# Find all unused customer sprites
	var unused_customer_sprites: Array[CustomerSprite]
	for customer_sprite in Global.customer_sprites:
		if !Global.customer_sprites_in_use.has(customer_sprite):
			unused_customer_sprites.append(customer_sprite)

	# Prefer using an unused one, else just get a random one.
	if unused_customer_sprites.size() > 0:
		customer_sprite_resource = unused_customer_sprites.pick_random()
	else:
		customer_sprite_resource = Global.customer_sprites.pick_random()
	Global.customer_sprites_in_use.append(customer_sprite_resource)
	body.texture = customer_sprite_resource.sprite
	
	get_stats()
	timer.timeout.connect(_on_timer_timeout)
	Events.customer_started_order.connect(_on_order_started)
	Events.order_approved.connect(_on_order_approved)
	# NOTE: not actually sure what this true argument does here lol
	# NOTE^2: it keeps the customers group tag if the packed scene file is saved
	add_to_group("customers", true)

	desired_drink = Global.drinks.filter(
		func(d: Drink):
			return d.is_unlocked(),
	).pick_random()

	spawn_anim()
	spawn_sound.play()


func _process(_delta: float) -> void:
	# uncomment to show time above customer head
	#waiting_indicator.visible = not timer.is_stopped()
	if not timer.is_stopped():
		percent_time_left = timer.time_left / timer.wait_time * 100
		if timer.wait_time == INF:
			percent_time_left = 100

	if percent_time_left >= 66:
		waiting_indicator.modulate = Color.GREEN
		bonus_points_for_time = 1
	elif percent_time_left >= 33:
		waiting_indicator.modulate = Color.ORANGE
		bonus_points_for_time = 0
	else:
		waiting_indicator.modulate = Color.RED
		bonus_points_for_time = -1

	waiting_bar.value = percent_time_left


func _exit_tree() -> void:
	Global.customer_sprites_in_use.erase(customer_sprite_resource)


func spawn_anim() -> void:
	const DUR := 0.25

	var t := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	t.tween_property(body, "transparency", 0, DUR).from(1)
	t.tween_property(self, "scale:y", 1, DUR).from(1.25)


func despawn_anim() -> void:
	const DUR := 0.25

	var t := create_tween().set_parallel().set_ease(Tween.EASE_IN)
	t.tween_property(body, "transparency", 1, DUR).from(0)
	t.tween_property(self, "scale:y", 1.25, DUR).from(1)

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
	timer.start()
	orders_made += 1


func _on_order_approved(customer: Customer) -> void:
	if customer != self:
		return

	timer.stop()
