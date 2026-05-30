class_name Customer
extends Node3D

signal drink_made_at_window

@export var body: Sprite3D
@export var waiting_indicator: Sprite3D
@export var waiting_bar: TextureProgressBar
@export var timer: Timer
@export var time_bonus_label: Label3D
@export var make_drink_button: Interactable
@export_dir var sprites_folder: String

var orders_made: int = 0
var bonus_points_for_time: int
var at_window: bool = false


func _ready() -> void:
	apply_random_sprite()
	make_drink_button.enabled = false
	make_drink_button.interacted.connect(func(): drink_made_at_window.emit())
	timer.timeout.connect(_on_timer_timeout)
	Events.customer_started_order.connect(_on_order_started)
	Events.order_approved.connect(_on_order_approved)
	Events.customer_left_machine.connect(_on_customer_left_machine)
	# NOTE: not actually sure what this true argument does here lol
	add_to_group("customers", true)

	waiting_indicator.hide()


func _physics_process(_delta: float) -> void:
	if timer.is_stopped():
		return

	waiting_bar.value = timer.time_left / timer.wait_time * 100

	if waiting_bar.value >= 66:
		waiting_indicator.modulate = Color.GREEN
		bonus_points_for_time = 0
	elif waiting_bar.value >= 33:
		waiting_indicator.modulate = Color.ORANGE
		bonus_points_for_time = 0
	else:
		waiting_indicator.modulate = Color.RED
		bonus_points_for_time = -1


func leave_store() -> void:
	waiting_indicator.hide()
	global_transform = Global.customer_leaving_spot.global_transform
	await get_tree().create_timer(randf_range(1, 2), false).timeout
	queue_free()


func apply_random_sprite() -> void:
	var sprites: Array[Resource]

	for file_name: String in ResourceLoader.list_directory(sprites_folder):
		if file_name.ends_with(".png"):
			sprites.append(ResourceLoader.load(sprites_folder.path_join(file_name)) as Resource)

	body.texture = sprites.pick_random()


func _on_timer_timeout() -> void:
	if not at_window:
		Events.customer_approached_window.emit(self)


func _on_order_started(customer: Customer) -> void:
	if customer != self or orders_made > 0:
		return
	await get_tree().process_frame
	timer.start()
	waiting_indicator.show()
	orders_made += 1


func _on_order_approved(customer: Customer) -> void:
	if customer != self:
		return

	timer.stop()

	await get_tree().create_timer(1, false).timeout
	Global.customer_score += bonus_points_for_time

	match bonus_points_for_time:
		1:
			time_bonus_label.modulate = Color.GREEN
			time_bonus_label.text = "⌚ bonus 🙂: +1"
		-1:
			time_bonus_label.modulate = Color.RED
			time_bonus_label.text = "⌚ 🙂 penalty: -1"


func _on_customer_left_machine(customer: Customer, drink_score) -> void:
	if customer != self:
		return

	time_bonus_label.hide()
	if (drink_score > -3):
		leave_store()
	else:
		Events.customer_approached_window.emit(self)
