# TODO: make the fixing minigame flow more readable
class_name Machine
extends Node3D

@export var spot_for_customer: Marker3D
# where the player gets put when they interact with machine
@export var spot_for_player: Marker3D
@export var progress_indicator: Control
@export var progress_bar: TextureProgressBar
@export var timer: Timer
@export var customer_order_indicator: Label
@export var final_order_indicator: Label
@export var price_label: Label
@export var drink_customer_score_label: Label
@export var make_drink_button: HoldButton
@export var accept_button: Button
@export var reject_button: Button
@export var refill_button: Interactable
@export var waiting_approval_indicator: Label
@export var fix_machine_button: Interactable
@export var breakdown_timer: Timer
@export var breakdown_sound: AudioStreamPlayer3D
@export var no_ingredients_sound: AudioStreamPlayer3D
@export var ingredients_bar: ProgressBar
@export var ing_too_low_label: Label3D
@export var tip_jar_item: Item
@export var spill_interactable: Interactable
@export var spill_sound: AudioStreamPlayer3D
@export var static_body: StaticBody3D
@export var spill_warning: Label
@export var manual_progress_bar: TextureProgressBar
@export var gui_3d: Gui3D
@export var customer_wait_indicator: Control
@export var customer_wait_bar: TextureProgressBar
@export var no_ingredients_warning: Control
@export var time_bonus_panel: PanelContainer
@export var time_bonus_label: Label
@export var order_breakdown: Control
@export var ordered_main_ingredient_icon: TextureRect
@export var ordered_liquid_icon: TextureRect
@export var ordered_extra_icon: TextureRect
@export var made_breakdown: Control
@export var made_main_ingredient_panel: OrderBreakdownElement
@export var made_liquid_panel: OrderBreakdownElement
@export var made_extra_panel: OrderBreakdownElement

var customer: Customer
var order: OrderData
var waiting_for_response: bool = false
var broken_down: bool = false
var max_ingredients: int = 100
var ingredients: int = max_ingredients:
	set(new_value):
		var change := new_value - ingredients

		if new_value > max_ingredients:
			change = max_ingredients - ingredients
			ingredients = max_ingredients
		else:
			ingredients = new_value

		if not change == 0:
			print("ingredients changed by %s on %s" % [change, name])
var spill_on_floor := false
var repair_minigames := ["Colors", "Arrows"]
var clean_spill_minigame := "SpillClean"
var refill_minigame := "Refill"


func _ready() -> void:
	get_stats()
	Events.items_updated.connect(get_stats)

	accept_button.pressed.connect(accept_order)
	make_drink_button.button_down.connect(
		func():
			if ingredients < Stats.current.ingredients_per_order:
				no_ingredients_warning.show()
				await get_tree().create_timer(0.5, false).timeout
				no_ingredients_warning.hide()
	)
	make_drink_button.hold_completed.connect(make_drink_manually)
	reject_button.pressed.connect(
		func():
			if ingredients < Stats.current.ingredients_per_order:
				no_ingredients_warning.show()
				await get_tree().create_timer(0.5, false).timeout
				no_ingredients_warning.hide()
			else:
				reject_order()
	)
	refill_button.interacted.connect(refill)
	fix_machine_button.interacted.connect(_on_fix_machine_button_pressed)

	breakdown_timer.wait_time = timer.wait_time / 2 + randf_range(-1, 1)

	Events.customer_approached_window.connect(_on_customer_approached_window)
	spill_interactable.interacted.connect(_on_clean_spill)

	progress_indicator.hide()
	price_label.hide()
	customer_order_indicator.hide()
	order_breakdown.hide()
	final_order_indicator.hide()


func _physics_process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100

	progress_indicator.visible = not timer.is_stopped()

	accept_button.visible = waiting_for_response
	reject_button.visible = waiting_for_response
	make_drink_button.visible = waiting_for_response
	make_drink_button.enabled = ingredients >= Stats.current.ingredients_per_order
	waiting_approval_indicator.visible = waiting_for_response
	made_breakdown.visible = waiting_for_response

	refill_button.visible = Global.holding_ingredients

	ingredients_bar.value = ingredients
	if ingredients < Stats.current.ingredients_per_order:
		ing_too_low_label.show()
		ingredients_bar.modulate = Color.RED
	else:
		if ingredients <= max_ingredients / 2.0:
			ingredients_bar.modulate = Color.YELLOW
		else:
			ingredients_bar.modulate = Color.GREEN
		ing_too_low_label.hide()

	spill_warning.visible = spill_on_floor

	manual_progress_bar.value = (
			make_drink_button.held_time / make_drink_button.time_to_hold * 100
	)

	manual_progress_bar.visible = make_drink_button.held_time > 0

	customer_wait_indicator.visible = customer != null and not customer.timer.is_stopped()

	if customer:
		var customer_timer: Timer = customer.timer

		customer_wait_bar.value = customer_timer.time_left / customer_timer.wait_time * 100

		if customer_wait_bar.value >= 66:
			customer_wait_indicator.modulate = Color.GREEN
		elif customer_wait_bar.value >= 33:
			customer_wait_indicator.modulate = Color.ORANGE
		else:
			customer_wait_indicator.modulate = Color.RED

		if customer.bonus_points_for_time > 0:
			time_bonus_label.text = "+%s⭐️ bonus" % [customer.bonus_points_for_time / 2.0]
		else:
			time_bonus_label.text = "%s⭐️ penalty" % [customer.bonus_points_for_time / 2.0]
		time_bonus_panel.visible = customer.bonus_points_for_time != 0

	if make_drink_button.held:
		Global.holding_make_drink_button = true


func set_customer(c: Customer) -> void:
	customer = c
	if customer != null:
		customer.global_position = spot_for_customer.global_position

		if spill_on_floor:
			Global.score_update_message = "customer stepped in spill"
			Global.employee_rating -= Stats.current.penalty_for_customer_stood_in_spill

	else:
		customer_order_indicator.hide()
		final_order_indicator.hide()
		price_label.hide()
		drink_customer_score_label.hide()
		waiting_for_response = false
		timer.stop()
		make_drink_button.held_time = 0


func get_stats() -> void:
	make_drink_button.time_to_hold = Stats.current.time_to_manually_make_drink
	timer.wait_time = Stats.current.machine_time_to_make_drink
	spill_interactable.time_to_hold = Stats.current.time_to_clean_up_spill


func machine_make_drink() -> void:
	await get_tree().create_timer(randf_range(1, 3), false).timeout

	# should stop us restarting order if order already auto started by us refilling
	if not timer.is_stopped():
		return

	# (i think) we emit this before returning because it starts the customer
	# wait timer
	Events.customer_started_order.emit(customer)

	if ingredients < Stats.current.ingredients_per_order or broken_down:
		return

	order = OrderData.new()
	order.ordered_drink = customer.desired_drink
	customer_order_indicator.text = (
			"ORDERED: %s (%s)"
			% [order.ordered_drink.name, Global.float_to_price(order.ordered_drink.price)]
	)

	ordered_main_ingredient_icon.texture = Global.main_ingredient_icons.get(order.ordered_drink.main_ingredient)
	ordered_liquid_icon.texture = Global.liquid_icons.get(order.ordered_drink.liquid)
	ordered_extra_icon.texture = Global.extra_icons.get(order.ordered_drink.extra)

	customer_order_indicator.show()
	order_breakdown.show()

	timer.start()

	if (
			randf() < Stats.current.chance_of_machine_breaking
			and Global.breakdowns_this_shift < Stats.current.max_breakdowns_per_shift
	):
		break_down()

	await timer.timeout

	consume_ingredients()

	# roll a random score based on chances from stat_data
	var ran_num: float = randf()
	var cumulative_score_chance: float = 0.0
	for score in Stats.current.score_chances:
		cumulative_score_chance += Stats.current.score_chances[score]
		if ran_num < cumulative_score_chance:
			order.score = score
			break

	# now find a random drink that has that score !
	var random_drink_score := 0
	var loops := 0
	const LOOP_LIMIT := 20

	while (
			(
					order.made_drink == null
					or random_drink_score != order.score
			)
			and loops < LOOP_LIMIT
	):
		var potential_drink_score := 0
		order.made_drink = Global.drinks.pick_random()
		for element in ["main_ingredient", "liquid", "extra"]:
			if order.made_drink.get(element) == order.ordered_drink.get(element):
				potential_drink_score += 1
			else:
				potential_drink_score -= 1
		random_drink_score = potential_drink_score
		loops += 1

	# use a fallback if we couldnt find a drink with that score
	# (i THINK this can happen but it might be rare)
	if loops > LOOP_LIMIT:
		print("no matching drink has the generated drink score (%s) for %s" % [order.score, order.made_drink.name])
		print("choosing a random fallback drink instead - this one has a score of %s" % random_drink_score)
		order.score = random_drink_score

	if order.ordered_drink.main_ingredient == order.made_drink.main_ingredient:
		order.main_correct = true
	if order.ordered_drink.liquid == order.made_drink.liquid:
		order.liquid_correct = true
	if order.ordered_drink.extra == order.made_drink.extra:
		order.extra_correct = true

	#completed_order = Global.full_wrong_drink # make every order fully wrong for testing

	display_drink_score()

	# TODO: move hardcoded tip chance here somewhere else
	if tip_jar_item in Global.owned_items and randf() < 0.25:
		order.tip = randf_range(0.25, 1)
		price_label.text += " (+ %s tip)" % Global.float_to_price(order.tip)

	if (
			randf() < Stats.current.machine_chance_of_spill
			and Global.spills_this_shift < Stats.current.max_spills_per_shift
	):
		spill_interactable.show()
		spill_sound.play()
		Events.alert_posted.emit("⚙️machine made a spill")
		Global.spills_this_shift += 1
		spill_on_floor = true

	final_order_indicator.text = (
			"MADE: %s (%s)"
			% [order.made_drink.name, Global.float_to_price(order.made_drink.price)]
	)
	final_order_indicator.show()

	waiting_for_response = true
	Events.order_completed.emit(customer)


func display_drink_score() -> void:
	# these all automatically set the icon, colour, and score of each icon 
	# from OrderBreakdownElement
	made_main_ingredient_panel.ingredient = order.made_drink.main_ingredient
	made_main_ingredient_panel.correct = order.main_correct
	made_liquid_panel.ingredient = order.made_drink.liquid
	made_liquid_panel.correct = order.liquid_correct
	made_extra_panel.ingredient = order.made_drink.extra
	made_extra_panel.ingredient = order.extra_correct

	price_label.text = Global.float_to_price(order.made_drink.price)
	price_label.show()

	if order.score < 0:
		drink_customer_score_label.modulate = Color.RED
		drink_customer_score_label.text = "🙂 %s⭐️" % (order.score / 2.0)
	elif order.score > 0:
		drink_customer_score_label.modulate = Color.GREEN
		drink_customer_score_label.text = "🙂 +%s⭐️" % (order.score / 2.0)
	drink_customer_score_label.show()

	if order.score == 3:
		final_order_indicator.modulate = Color.GREEN
	else:
		final_order_indicator.modulate = Color.RED


func fix_machine() -> void:
	fix_machine_button.hide()
	broken_down = false
	gui_3d.interactable.enabled = true
	if customer:
		customer_order_indicator.show()
		timer.paused = false


# this isnt inlined cos both manual and automatic drinks call this
func consume_ingredients() -> void:
	ingredients -= Stats.current.ingredients_per_order
	if ingredients < Stats.current.ingredients_per_order:
		Events.alert_posted.emit("🫘 machine ran out of ingredients")
		no_ingredients_sound.play()


func clean_up_spill() -> void:
	Events.minigame_end.disconnect(clean_up_spill)
	Events.minigame_cancelled.disconnect(cancel_clean_spill)
	spill_interactable.hide()
	spill_on_floor = false


func refill() -> void:
	Events.minigame_active.emit(refill_minigame)

	await Events.minigame_end

	Global.holding_ingredients = false
	@warning_ignore("narrowing_conversion")
	ingredients += (
			Stats.current.ingredients_per_bag * Global.refill_minigame_accuracy
	)

	# TODO: separate this out ? its not explicit its doing this when we just call
	# 'refill()'
	if (
			timer.is_stopped()
			and customer
			and not broken_down
			and not waiting_for_response
	):
		machine_make_drink()


func cancel_fix_minigame() -> void:
	Events.minigame_end.disconnect(_on_machine_fixed)
	Events.minigame_cancelled.disconnect(cancel_fix_minigame)


func cancel_clean_spill() -> void:
	Events.minigame_end.disconnect(clean_up_spill)
	Events.minigame_cancelled.disconnect(cancel_clean_spill)


func accept_order() -> void:
	gui_3d.exit()

	customer_order_indicator.text = ""
	final_order_indicator.modulate = Color.WHITE
	final_order_indicator.text = "dispensing drink to customer . . ."

	waiting_for_response = false
	Events.order_approved.emit(customer)

	drink_customer_score_label.hide()
	price_label.show()
	Global.score_update_message = "sold %s" % order.made_drink.name
	Global.daily_profit += order.made_drink.price + order.tip

	await get_tree().create_timer(0.5, false).timeout

	price_label.hide()
	drink_customer_score_label.show()
	Global.score_update_message = "customer rated %s" % order.made_drink.name
	Global.employee_rating += order.score
	await get_tree().create_timer(0.5, false).timeout

	drink_customer_score_label.hide()
	order_breakdown.hide()

	# -------------------------------------------------
	# Check if the drink score is -3 to make them angry (red)
	# pretty clunky right now, with a score check here and a score check in _on_customer_left_machine
	# NOTE: disabled for now !
	#if (order.score <= -3):
	#customer.body.modulate = Color(0.8, 0.3, 0.3, 1.0)
	# -------------------------------------------------

	await get_tree().create_timer(1.5, false).timeout
	Events.customer_left_machine.emit(customer, order.score)
	set_customer(null)


func reject_order() -> void:
	gui_3d.exit()
	if ingredients < Stats.current.ingredients_per_order:
		return
	final_order_indicator.text = "order rejected! \n making a new drink"
	price_label.hide()
	drink_customer_score_label.hide()
	waiting_for_response = false

	machine_make_drink()


func make_drink_manually() -> void:
	gui_3d.exit()

	if ingredients < Stats.current.ingredients_per_order:
		return

	consume_ingredients()

	order.made_drink = order.ordered_drink
	order.score = 3
	final_order_indicator.text = (
			"you made: %s (%s)"
			% [order.made_drink.name, Global.float_to_price(order.made_drink.price)]
	)
	display_drink_score()

	Events.order_completed.emit(customer)
	customer.timer.stop()
	waiting_for_response = false
	price_label.hide()
	drink_customer_score_label.hide()
	await get_tree().create_timer(1, false).timeout
	accept_order()


func break_down() -> void:
	breakdown_timer.start()
	await breakdown_timer.timeout

	if gui_3d.player_using_me:
		gui_3d.exit()
	gui_3d.interactable.enabled = false
	customer_order_indicator.hide()
	fix_machine_button.show()
	breakdown_sound.play()
	Events.alert_posted.emit("⚙️ machine broke down")
	Global.breakdowns_this_shift += 1

	timer.paused = true
	broken_down = true


func _on_clean_spill() -> void:
	Events.minigame_active.emit(clean_spill_minigame)
	Events.minigame_end.connect(clean_up_spill)
	Events.minigame_cancelled.connect(cancel_clean_spill)


func _on_fix_machine_button_pressed() -> void:
	# we connect and disconnect these signals here instead of in _ready() so other machines dont get
	# the signal and do unintended things
	Events.minigame_end.connect(_on_machine_fixed)
	Events.minigame_cancelled.connect(cancel_fix_minigame)
	Events.minigame_active.emit(repair_minigames.pick_random())


func _on_machine_fixed() -> void:
	Events.minigame_end.disconnect(_on_machine_fixed)
	Events.minigame_cancelled.disconnect(cancel_fix_minigame)
	fix_machine()


func _on_customer_approached_window(customer_at_window: Customer) -> void:
	if customer_at_window != customer:
		return

	set_customer(null)


class OrderData:
	var ordered_drink: Drink
	var made_drink: Drink
	var main_correct: bool = false
	var liquid_correct: bool = false
	var extra_correct: bool = false
	var score: int
	var tip: float = 0.0
