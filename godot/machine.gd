class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
@export var progress_indicator: Sprite3D
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var customer_order_indicator: Label3D
@export var final_order_indicator: Label3D
@export var score_label: Label3D
@export var make_drink_button: Interactable
@export var accept_button: Interactable
@export var reject_button: Interactable
@export var add_ing_button: Interactable
@export var waiting_approval_indicator: Label3D
@export var fix_machine_button: Interactable
@export var breakdown_timer: Timer
@export var breakdown_sound: AudioStreamPlayer3D
@export var no_ingredients_sound: AudioStreamPlayer3D
@export var drink_customer_score_label: Label3D
@export var ingredients_bar: ProgressBar
@export var ing_too_low_label: Label3D

var customer: Customer:
	set(new_customer):
		customer = new_customer
		if customer != null:
			customer.global_position = spot_for_customer.global_position
			await get_tree().create_timer(randf_range(1, 3), false).timeout
			start_order()
		else:
			customer_order_indicator.hide()
			final_order_indicator.hide()
			score_label.hide()
			drink_customer_score_label.hide()
			waiting_for_response = false
			timer.stop()
var customers_order: Drink
var completed_order: Drink
var waiting_for_response: bool = false
var drink_score: int = 0
var drink_correct: bool = false
var broken_down: bool = false
var max_ingredients: int = 100
var ingredients = max_ingredients


func _ready() -> void:
	accept_button.interacted.connect(_on_accept_button_presssed)
	reject_button.interacted.connect(_on_reject_button_pressed)
	add_ing_button.interacted.connect(_on_add_ing_button_pressed)
	make_drink_button.time_to_hold = Stats.time_to_manually_make_drink
	make_drink_button.interacted.connect(_on_make_drink_button_pressed)
	fix_machine_button.interacted.connect(_on_fix_machine_button_pressed)
	timer.timeout.connect(_on_order_finished)
	timer.wait_time = Stats.machine_time_to_make_drink
	breakdown_timer.wait_time = timer.wait_time / 2
	breakdown_timer.timeout.connect(_on_breakdown_timer_timeout)
	Events.customer_approached_window.connect(_on_customer_approached_window)

	progress_indicator.hide()
	score_label.hide()
	customer_order_indicator.hide()
	final_order_indicator.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100

	progress_indicator.visible = not timer.is_stopped()
	accept_button.visible = waiting_for_response
	reject_button.visible = waiting_for_response
	make_drink_button.visible = waiting_for_response
	add_ing_button.visible = Global.holding_ingredients
	waiting_approval_indicator.visible = waiting_for_response
	ingredients_bar.value = ingredients
	if ingredients_bar.value < Stats.ingredients_per_order:
		ing_too_low_label.show()
		ingredients_bar.modulate = Color.RED
		reject_button.display_name = "[color=pink]🚫not enough ingredients"
		make_drink_button.display_name = "[color=pink]🚫no ingredients"
	else:
		ingredients_bar.modulate = Color.GREEN
		ing_too_low_label.hide()
		reject_button.display_name = "[color=red]reject drink (retry)"
		make_drink_button.display_name = "[color=yellow]remake drink by hand"


func start_order() -> void:
	# (i think) we emit this before returning because it starts the customer
	# wait timer
	Events.customer_started_order.emit(customer)

	if ingredients < Stats.ingredients_per_order:
		return

	if broken_down:
		return

	customers_order = Global.drinks.pick_random()
	customer_order_indicator.text = (
		"customer ordered %s (%s)"
		% [customers_order.name, Global.float_to_price(customers_order.price)]
	)
	customer_order_indicator.show()
	timer.start()

	if randf() < Stats.chance_of_machine_breaking:
		breakdown_timer.start()


func score_drink() -> void:
	drink_score = 0
	drink_correct = false

	for element in ["main_ingredient", "liquid", "extra"]:
		if completed_order.get(element) == customers_order.get(element):
			drink_score += 1
		else:
			drink_score -= 1

	score_label.modulate = Color.GREEN
	score_label.text = Global.float_to_price(completed_order.price)

	score_label.show()

	if drink_score == 3:
		drink_correct = true

	drink_customer_score_label.text = ""
	if drink_score < 0:
		drink_customer_score_label.modulate = Color.RED
		drink_customer_score_label.text += "🙂 "
		drink_customer_score_label.text += str(drink_score)
	elif drink_score > 0:
		drink_customer_score_label.modulate = Color.GREEN
		drink_customer_score_label.text += "🙂+ "
		drink_customer_score_label.text += str(drink_score)
	drink_customer_score_label.show()

	if drink_correct:
		final_order_indicator.modulate = Color.GREEN
	else:
		final_order_indicator.modulate = Color.RED


func fix_machine() -> void:
	fix_machine_button.hide()
	broken_down = false
	if customer:
		customer_order_indicator.show()
		timer.start()


func _on_order_finished() -> void:
	ingredients -= Stats.ingredients_per_order
	if ingredients <= Stats.ingredients_per_order:
		Events.alert_posted.emit("❗️🫘 machine ran out of ingredients")
		no_ingredients_sound.play()
	completed_order = null
	if randf() < Stats.machine_accuracy:
		completed_order = customers_order
	else:
		while (
			completed_order == null
			or completed_order == customers_order
		):
			completed_order = Global.drinks.pick_random()
	#completed_order = Global.full_wrong_drink # make every order fully wrong for testing
	final_order_indicator.text = (
		"machine made: %s (%s)"
		% [completed_order.name, Global.float_to_price(completed_order.price)]
	)
	final_order_indicator.show()
	score_drink()
	waiting_for_response = true
	Events.order_completed.emit(customer)


func _on_accept_button_presssed() -> void:
	final_order_indicator.modulate = Color.WHITE
	final_order_indicator.text = "dispensing drink to customer"
	waiting_for_response = false
	Events.order_approved.emit(customer)
	drink_customer_score_label.hide()
	score_label.show()
	Global.score_update_message = "sold %s" % completed_order.name
	Stats.daily_profit += completed_order.price
	await get_tree().create_timer(0.5, false).timeout
	score_label.hide()
	drink_customer_score_label.show()
	Global.score_update_message = "customer rated %s" % completed_order.name
	Stats.employee_rating += drink_score
	await get_tree().create_timer(0.5, false).timeout
	drink_customer_score_label.hide()

	# -------------------------------------------------
	# Check if the drink score is -3 to make them angry (red)
	# pretty clunky right now, with a score check here and a score check in _on_customer_left_machine
	if (drink_score <= -3):
		#await get_tree().create_timer(randf_range(0.3, 1), false).timeout
		customer.body.modulate = Color(0.8, 0.3, 0.3, 1.0)
	# -------------------------------------------------

	await get_tree().create_timer(1.5, false).timeout
	Events.customer_left_machine.emit(customer, drink_score)
	customer = null


func _on_reject_button_pressed() -> void:
	if ingredients < Stats.ingredients_per_order:
		return
	final_order_indicator.text = "order rejected! \n making a new drink"
	timer.start()
	progress_indicator.show()
	waiting_for_response = false


func _on_make_drink_button_pressed() -> void:
	if ingredients < Stats.ingredients_per_order:
		return
	completed_order = customers_order
	final_order_indicator.text = (
		"you made: %s (%s)"
		% [completed_order.name, Global.float_to_price(completed_order.price)]
	)
	score_drink()
	Events.order_completed.emit(customer)
	customer.timer.stop()
	waiting_for_response = false
	score_label.hide()
	drink_customer_score_label.hide()
	await get_tree().create_timer(1, false).timeout
	_on_accept_button_presssed()


func _on_add_ing_button_pressed() -> void:
	Global.holding_ingredients = false
	ingredients += Stats.ingredients_per_bag
	if ingredients > max_ingredients:
		ingredients = max_ingredients

	if (
		timer.is_stopped()
		and customer
		and not broken_down
		and not waiting_for_response
	):
		start_order()


func _on_breakdown_timer_timeout() -> void:
	customer_order_indicator.hide()
	timer.stop()
	fix_machine_button.show()
	broken_down = true
	breakdown_sound.play()
	Events.alert_posted.emit("❗️⚙️ machine broke down")


func _on_fix_machine_button_pressed() -> void:
	# we connect and disconnect these signals here instead of in _ready() so other machines dont get
	# the signal and do unintended things
	Events.minigame_end.connect(_on_minigame_end)
	Events.minigame_cancelled.connect(_on_minigame_cancelled)
	Events.minigame_active.emit()


func _on_minigame_end() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)
	fix_machine()


func _on_minigame_cancelled() -> void:
	Events.minigame_end.disconnect(_on_minigame_end)
	Events.minigame_cancelled.disconnect(_on_minigame_cancelled)


func _on_customer_approached_window(customer_at_window: Customer) -> void:
	if customer_at_window != customer:
		return

	customer = null
