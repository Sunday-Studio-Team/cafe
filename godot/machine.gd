# this script is for all the behaviour of the machine + its ui
# (machine_3d_gui.gd handles the player interaction and passing mouse input here)
class_name Machine
extends Node3D

signal drink_prepared

const BLAST_LAUNCH_MAGNITUDE: float = 20.0
const REPAIR_MINIGAMES := ["Colors", "Arrows"]
const MANUAL_DRINK_MINIGAMES := ["Captcha"]
const CLEAN_SPILL_MINIGAME := "SpillClean"
const REFILL_MINIGAME := "Refill"

@export var static_body: StaticBody3D
@export var gui_3d: Gui3D
@export var timer: Timer
@export var breakdown_timer: Timer
@export var fix_machine_button: Interactable
@export var spill_interactable: Interactable
@export var spill_clean_particles: GPUParticles3D
@export_category("Markers")
@export var spot_for_player: Marker3D
@export var spot_for_customer: Marker3D
@export var start_of_customer_queue_marker: Marker3D
@export var end_of_customer_queue_marker: Marker3D
@export_category("UI")
@export var progress_indicator: Control
@export var progress_bar: TextureProgressBar
@export var tippy_progress_sprite: TextureRect
@export var accept_button: Button
@export var _price_label_accept: Label
@export var _rating_loss_on_accept_label: Label
@export var make_drink_button: Button
@export var _rating_gain_on_remake_label: Label
@export var remake_ingredients_cost_label: Label
@export var refill_button: Button
@export var ordered_drink_name_label: Label
@export var made_drink_name_label: Label
@export var _price_label_remake: Label
@export var ingredients_bar: ProgressBar
@export var ing_too_low_label: Label3D
@export var spill_warning: Label
@export var customer_wait_indicator: Control
@export var customer_wait_bar: TextureProgressBar
@export var no_ingredients_warning: Control
@export var get_ingredients_prompt: Control
@export var order_breakdown: Control
@export var ordered_main_ingredient_icon: TextureRect
@export var ordered_liquid_icon: TextureRect
@export var ordered_extra_icon: TextureRect
@export var ordered_drink_icon: TextureRect
@export var made_breakdown: Control
@export var made_main_ingredient_panel: OrderBreakdownElement
@export var made_liquid_panel: OrderBreakdownElement
@export var made_extra_panel: OrderBreakdownElement
@export var made_drink_icon: TextureRect
@export_category("Audio")
@export var hum_sound: AudioStreamPlayer3D
@export var done_sound: AudioStreamPlayer3D
@export var spill_clean_sound: AudioStreamPlayer3D
@export var fixed_sound: AudioStreamPlayer3D
@export var spill_sound: AudioStreamPlayer3D
@export var breakdown_sound: AudioStreamPlayer3D
@export var hammer_hit_sound: AudioStreamPlayer
@export var no_ingredients_sound: AudioStreamPlayer3D
@export var airhorn_sound: AudioStreamPlayer
@export_category("Popups")
@export var popup_go_to_spill: PackedScene # tutorial popup that tells player to go to the spill



var customer: Customer
var queued_customers: Array[Customer]
var order: OrderData
var waiting_for_response: bool = false
var broken_down: bool = false
var make_drink_locked: bool = false
var next_drink_forced_perfect: bool = false
var next_drink_forced_incorrect: bool = false
var ingredients: int:
	set(new_value):
		if new_value > Stats.current.machine_max_ingredients:
			ingredients = Stats.current.machine_max_ingredients
		elif new_value < 0:
			ingredients = 0
		else:
			ingredients = new_value
var spill_on_floor := false

var test_1: int = 0
var test_2: int = 0
var test_3: int = 0

func _ready() -> void:
	get_stats()
	Events.items_updated.connect(get_stats)

	ingredients = Stats.current.machine_starting_ingredients
	breakdown_timer.wait_time = 0.5

	accept_button.pressed.connect(
		func():
			Global.tutorial_drink_accepted = true
			accept_order(false)
	)
	make_drink_button.pressed.connect(_on_remake_drink_button_pressed)
	refill_button.pressed.connect(
		func():
			if Global.holding_ingredients:
				refill()
			else:
				get_ingredients_prompt.show()
				await get_tree().create_timer(0.5, false).timeout
				get_ingredients_prompt.hide()
	)
	fix_machine_button.interacted.connect(_on_fix_machine_button_pressed)
	fix_machine_button.used_active_item.connect(on_active_item_used_fix_machine)
	gui_3d.interactable.used_active_item.connect(on_active_item_used)
	spill_interactable.interacted.connect(_on_clean_spill)

	ordered_drink_name_label.hide()
	order_breakdown.hide()
	made_drink_name_label.hide()

	# glowing fx on spill warning
	var t := create_tween().set_loops()
	t.tween_property(spill_warning, "modulate", Color.GOLD, 1)
	t.tween_property(spill_warning, "modulate", Color.RED, 1)


func _process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100

	progress_indicator.visible = not timer.is_stopped()
	
	
	
	accept_button.visible = waiting_for_response
	make_drink_button.visible = waiting_for_response
	make_drink_button.disabled = ingredients < Stats.current.ingredients_per_order or make_drink_locked
	made_breakdown.visible = waiting_for_response
	made_drink_icon.visible = waiting_for_response

	# uncomment if we want to show detailed ingredients cost for remakes
	#remake_ingredients_cost_label.text = (
	#"-%s%%🫘" % int(
		#Stats.current.ingredients_per_order / float(Stats.current.machine_max_ingredients
		#) * 100)
	#)

	ingredients_bar.value = ingredients
	if ingredients < Stats.current.ingredients_per_order:
		ing_too_low_label.show()
		ingredients_bar.modulate = Color.RED
	else:
		if ingredients <= Stats.current.machine_max_ingredients / 2.0:
			ingredients_bar.modulate = Color.YELLOW
		else:
			ingredients_bar.modulate = Color.GREEN
		ing_too_low_label.hide()

	spill_warning.visible = spill_on_floor

	customer_wait_indicator.visible = (
		customer != null
		and not customer.timer.is_stopped()
		and not Global.day == 0
		)

	if customer:
		var customer_timer: Timer = customer.timer

		customer_wait_bar.value = customer_timer.time_left / customer_timer.wait_time * 100

		if customer_wait_bar.value >= 66:
			customer_wait_indicator.modulate = Color.GREEN
		elif customer_wait_bar.value == 34:
			Events.customer_low_time_warning.emit()
		elif customer_wait_bar.value >= 33:
			customer_wait_indicator.modulate = Color.ORANGE
		else:
			customer_wait_indicator.modulate = Color.RED

	_process_queued_customers()


func add_customer_to_queue(new_customer: Customer) -> void:
	queued_customers.append(new_customer)
	_customer_queue_update_visuals()


func force_next_drink_perfect() -> void:
	next_drink_forced_perfect = true


func force_next_drink_incorrect() -> void:
	next_drink_forced_incorrect = true


func _customer_queue_update_visuals() -> void:
	var i: int = 0
	for queued_customer in queued_customers:
		var ratio_along_queue: float = (i as float) / Stats.current.max_customers_queued_per_machine
		var queue_global_position: Vector3 = (
			start_of_customer_queue_marker.global_position.lerp(
				end_of_customer_queue_marker.global_position,
				ratio_along_queue
			)
		)
		queued_customer.move_to(queue_global_position)
		i += 1


func _process_queued_customers() -> void:
	if queued_customers.size() > 0:
		if customer != null:
			return
		var new_current_customer: Customer = queued_customers.pop_front()
		_customer_queue_update_visuals()
		await _set_customer(new_current_customer)
		check_for_stepping_in_spill()
		machine_make_drink()


func check_for_stepping_in_spill() -> void:
	if spill_on_floor:
		var rating_loss: float = Stats.current.customer_steps_on_spill_rating_loss_each_day[Global.day]
		Events.alert_posted.emit("-%s A customer stood in a spill!" % rating_loss, UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
		Global.employee_rating -= rating_loss


func blast_player_from_using_machine() -> void:
	if gui_3d.player_using_me:
		if Global.minigame_active:
			Events.force_close_minigame.emit()
		gui_3d.exit_without_camera_tween()

	# Get the direction vector from machine to player.
	var machine_to_player_normalized: Vector3 = global_position.direction_to(Global.player.global_position)

	# Flatten it.
	machine_to_player_normalized.y = 0.0
	machine_to_player_normalized = machine_to_player_normalized.normalized()

	# Scale it.
	var launch_vector: Vector3 = machine_to_player_normalized * BLAST_LAUNCH_MAGNITUDE

	Global.player.velocity += launch_vector


func set_order_action_buttons_available(button_case: String) -> void:
	accept_button.disabled = true
	make_drink_locked = true
	refill_button.disabled = true

	match button_case:
		"accept":
			accept_button.disabled = false
		"make_drink":
			make_drink_locked = false
		"refill":
			refill_button.disabled = false
		"all":
			accept_button.disabled = false
			make_drink_button.disabled = false
			refill_button.disabled = false
		"none":
			pass
		_:
			print("invalid button_case passed to set_order_action_buttons_available()")


# called from inside spill() (so that itll still show if we trigger the spill
# via a console command etc)
func show_tutorial_go_clean_spill() -> void:
	if OS.has_feature("skip_popups"):
		return

	while (Global.in_ui):
		await get_tree().create_timer(0.25).timeout
		#janky way to make sure the popup tutorial does not show up while in a menu/minigame

	await get_tree().create_timer(0.75).timeout # allows audio to play first
	if (Global.day == 0) and (Global.tutorial_go_clean_spill_shown == false):
		Global.tutorial_go_clean_spill_shown = true
		Global.in_tutorial_screen = true

		#hide tablet so it's not in the way.
		var tablet = get_parent().get_parent().find_child("Tablet")
		tablet.hide()

		#CHANGE POPUP HERE
		var popup = popup_go_to_spill.instantiate()
		add_child(popup)
		get_tree().paused = true # this kinda works but its janky

		var button = popup.get_node("NextButton")
		popup.move_to_front() # this was an attempt to fix issue, does not really do anything
		popup.process_mode = Node.PROCESS_MODE_ALWAYS

		button.pressed.connect(
			func():
				get_tree().paused = false
				popup.queue_free()
		)

		#add functionality to allow use of Esc
		#add functionality so that button makes popup disappear
		#hide tablet
		#

		await popup.tree_exited # delays some code until event occurs
		tablet.show()
		Global.in_tutorial_screen = false # re enable pause


func _set_customer(new_customer: Customer) -> void:
	customer = new_customer
	if customer != null:
		customer.wait_timed_out.connect(_on_customer_wait_timed_out, CONNECT_ONE_SHOT)
		await customer.move_to(spot_for_customer.global_position)
	else:
		ordered_drink_name_label.hide()
		made_drink_name_label.hide()
		order_breakdown.hide()
		waiting_for_response = false
		timer.stop()
		if Global.making_drink_manually and gui_3d.player_using_me:
			# NOTE: not sure these are both correct + necessary to cancel a minigame
			# but this seems to behave correctly
			Events.force_close_minigame.emit()
			Events.minigame_cancelled.emit()


func _on_customer_wait_timed_out(timed_out_customer: Customer) -> void:
	if customer == timed_out_customer:
		var rating_loss: float = Stats.current.machine_customer_timed_out_rating_loss_each_day[Global.day]
		Events.alert_posted.emit("-%s Customer not served order, left..." % rating_loss, UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
		Global.employee_rating -= rating_loss
		customer.leave_store()
		_set_customer(null)


func get_stats() -> void:
	timer.wait_time = Stats.current.machine_time_to_make_drink


func machine_make_drink() -> void:
	await get_tree().create_timer(randf_range(1, 1), false).timeout

	# should stop us restarting order if order already auto started by us refilling
	if not timer.is_stopped():
		return

	# something weird might have happened like we airhorned customer away
	# during short delay just then so good to check this
	if not customer:
		return

	# (i think) we emit this before returning because it starts the customer
	# wait timer
	Events.customer_started_order.emit(customer)

	if ingredients < Stats.current.ingredients_per_order or broken_down:
		return

	hum_sound.pitch_scale = randf_range(0.95, 1.05)
	hum_sound.play()

	order = OrderData.new()
	order.ordered_drink = customer.desired_drink
	ordered_drink_name_label.text = (
			"%s (%s)"
			% [order.ordered_drink.name, Global.float_to_price(order.ordered_drink.price * Stats.current.drink_price_multiplier_each_day[Global.day])]
	)

	ordered_main_ingredient_icon.texture = order.ordered_drink.main_ingredient.icon
	ordered_liquid_icon.texture = order.ordered_drink.liquid.icon
	if (order.ordered_drink.extra):
		ordered_extra_icon.texture = order.ordered_drink.extra.icon
	else:
		ordered_extra_icon.texture = null
	ordered_drink_icon.texture = order.ordered_drink.icon

	# NOTE: experiment: commented out for now to simplify ui
	#customer_order_indicator.show()
	order_breakdown.show()

	timer.start()
	Events.machine_making_drink.emit()

	var breaking_chance_at_shift_start_for_day: float = (
		Stats.current.chance_of_machine_breaking_at_shift_start_each_day[Global.day]
	)
	var breaking_chance_at_shift_end_for_day: float = (
		Stats.current.chance_of_machine_breaking_at_shift_end_each_day[Global.day]
	)
	var breaking_chance_now: float = (
		remap(
			Global.shift_progress_ratio,
			0.0,
			1.0,
			breaking_chance_at_shift_start_for_day,
			breaking_chance_at_shift_end_for_day)
	)

	if (
			randf() <= breaking_chance_now
			and Global.breakdowns_this_shift < Stats.current.max_breakdowns_per_shift_each_day[Global.day]
	):
		break_down()

	await timer.timeout

	hum_sound.stop()
	done_sound.play()

	consume_ingredients()

	# Roll a random number of ingredients to differ.
	const ingredient_types_count: int = 3
	var target_drink_diff: int = randi_range(0, ingredient_types_count)
	if next_drink_forced_perfect:
		target_drink_diff = 0
		next_drink_forced_perfect = false
	elif next_drink_forced_incorrect:
		target_drink_diff = 2
		next_drink_forced_incorrect = false

	var unlocked_drinks: Array[Drink]
	for drink in Global.drinks:
		if drink.is_unlocked():
			unlocked_drinks.append(drink)
	randomize()
	var made_drink: Drink = null
	for drink in unlocked_drinks:
		# Find a drink with the specified number of
		var drink_diff: int = _calculate_drink_diff(order.ordered_drink, drink)
		if drink_diff == target_drink_diff:
			made_drink = drink
	if made_drink == null:
		# Use a fallback random drink.
		made_drink = unlocked_drinks.pick_random()
	order.made_drink = made_drink

	# Add rating gain on remake for each incorrect ingredient.
	if order.ordered_drink.main_ingredient == order.made_drink.main_ingredient:
		order.main_correct = true
	else:
		order.main_correct = false
		test_1 += 1
		print("%s Main Star Gain Count: %d" % [self.name, test_1])
		order.star_rating_gain_for_remake += (
			Stats.current.remade_drink_star_rating_gain_for_incorrect_main_each_day[Global.day]
		)
	if order.ordered_drink.liquid == order.made_drink.liquid:
		order.liquid_correct = true
	else:
		order.liquid_correct = false
		test_2 += 1
		print("%s Liquid Star Gain Count: %d" % [self.name, test_2])
		order.star_rating_gain_for_remake += (
			Stats.current.remade_drink_star_rating_gain_for_incorrect_liquid_each_day[Global.day]
		)
	if order.ordered_drink.extra == order.made_drink.extra:
		order.extra_correct = true
	else:
		order.extra_correct = false
		test_3 += 1
		print("%s Extra Star Gain Count: %d" % [self.name, test_3])
		order.star_rating_gain_for_remake += (
			Stats.current.remade_drink_star_rating_gain_for_incorrect_extra_each_day[Global.day]
		)

	# Calculate scaled price
	order.final_order_price = order.made_drink.price * Stats.current.drink_price_multiplier_each_day[Global.day]

	# Calculate star rating loss if accepted
	if order.star_rating_gain_for_remake == 0.0:
		order.star_rating_loss_if_accept = 0.0
	else:
		order.star_rating_loss_if_accept = maxf(0.1, snappedf(
			order.star_rating_gain_for_remake * Stats.current.accept_incorrect_drink_star_rating_multiplier,
			Stats.current.accept_incorrect_drink_star_rating_rounding))

	display_drink_score()

	var shift_progress_ratio: float = Global.shift_progress_ratio
	var spill_chance_at_shift_start_for_day: float = (
		Stats.current.chance_of_machine_spill_at_shift_start_each_day[Global.day]
	)
	var spill_chance_at_shift_end_for_day: float = (
		Stats.current.chance_of_machine_spill_at_shift_end_each_day[Global.day]
	)
	var spill_chance_now: float = (
		remap(
			shift_progress_ratio,
			0.0,
			1.0,
			spill_chance_at_shift_start_for_day,
			spill_chance_at_shift_end_for_day
		)
	)
	if (
			randf() < spill_chance_now
			and Global.spills_this_shift < Stats.current.max_spills_per_shift_each_day[Global.day]
	):
		spill()

	made_drink_name_label.text = (
			"%s (%s)"
			% [order.made_drink.name, Global.float_to_price(order.final_order_price)]
	)
	# NOTE: experiment: commented out for now to simplify ui
	#final_order_indicator.show()


	waiting_for_response = true
	drink_prepared.emit()
	Events.order_completed.emit(customer)


## 1 per differing ingredient.
func _calculate_drink_diff(correct_drink: Drink, made_drink: Drink) -> int:
	var differing_ingredient_count: int = 0
	if correct_drink.main_ingredient != made_drink.main_ingredient:
		differing_ingredient_count += 1
	if correct_drink.liquid != made_drink.liquid:
		differing_ingredient_count += 1
	if correct_drink.extra != made_drink.extra:
		differing_ingredient_count += 1
	return differing_ingredient_count


func spill() -> void:
	spill_interactable.show()
	spill_sound.play()
	Events.alert_posted.emit("A machine spilled!", UI.AlertIconType.MACHINE, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
	Global.spills_this_shift += 1
	spill_on_floor = true
	show_tutorial_go_clean_spill()


func display_drink_score() -> void:


	# these all automatically set the icon, colour, and score of each icon
	# from OrderBreakdownElement
	made_main_ingredient_panel.ingredient = order.made_drink.main_ingredient
	made_main_ingredient_panel.correct = order.main_correct
	made_liquid_panel.ingredient = order.made_drink.liquid
	made_liquid_panel.correct = order.liquid_correct

	if order.made_drink.extra:
		made_extra_panel.ingredient = order.made_drink.extra
	else:
		made_extra_panel.ingredient = null
	made_extra_panel.correct = order.extra_correct
	made_drink_icon.texture = order.made_drink.icon

	var price_labels_text: String = "+%s" % Global.float_to_price(order.final_order_price)
	_price_label_remake.text = price_labels_text
	_price_label_accept.text = price_labels_text

	if order.star_rating_gain_for_remake > 0.0:
		_rating_gain_on_remake_label.modulate = Color.GREEN
		var star_rating_gain_if_remade: float = order.star_rating_gain_for_remake
		_rating_gain_on_remake_label.text = "🙂 +%s⭐️" % star_rating_gain_if_remade
	elif order.star_rating_gain_for_remake == 0.0:
		_rating_gain_on_remake_label.modulate = Color.DARK_GRAY
		var star_rating_gain_if_remade: float = 0
		_rating_gain_on_remake_label.text = "+%s⭐️" % star_rating_gain_if_remade

	if order.star_rating_loss_if_accept > 0.0:
		_rating_loss_on_accept_label.modulate = Color.RED
		var star_rating_loss_if_accept: float = order.star_rating_loss_if_accept
		_rating_loss_on_accept_label.text = "☹️ -%s⭐" % star_rating_loss_if_accept
	elif order.star_rating_loss_if_accept == 0.0:
		_rating_loss_on_accept_label.modulate = Color.DARK_GRAY
		var star_rating_loss_if_accept: float = 0
		_rating_loss_on_accept_label.text = "-%s⭐️" % star_rating_loss_if_accept

	if order.star_rating_gain_for_remake == 0.0:
		made_drink_name_label.modulate = Color.GREEN
	else:
		made_drink_name_label.modulate = Color.RED


func fix_machine(hammer: bool = false) -> void:
	if hammer:
		hammer_hit_sound.play()
	fixed_sound.play()

	fix_machine_button.visible = false
	var t := create_tween().tween_property(
		fix_machine_button,
		"scale",
		Vector3.ZERO,
		0.25,
	)
	await t.finished
	fix_machine_button.visible = true
	fix_machine_button.hide()
	fix_machine_button.scale = Vector3.ONE
	broken_down = false
	timer.paused = false
	gui_3d.interactable.visible = true
	if customer:
		# during normal gameplay, breakdowns always happen mid order,
		# but when we force a breakdown thru the console we have to check some stuff
		if timer.time_left != 0:
			# NOTE: experiment: commented out for now to simplify ui
			#customer_order_indicator.show()
			hum_sound.pitch_scale = randf_range(0.95, 1.05)
			hum_sound.play()
		elif waiting_for_response:
			return
		else:
			machine_make_drink()


func consume_ingredients() -> void:
	ingredients -= Stats.current.ingredients_per_order
	if ingredients < Stats.current.ingredients_per_order:
		Events.alert_posted.emit("A machine ran out of ingredients!", UI.AlertIconType.MACHINE)
		no_ingredients_sound.play()


func clean_up_spill() -> void:
	Events.minigame_end.disconnect(clean_up_spill)
	Events.minigame_cancelled.disconnect(cancel_clean_spill)
	spill_interactable.hide()
	spill_on_floor = false
	spill_clean_sound.play()
	spill_clean_particles.restart()

	var rating_gained: float = Stats.current.spill_cleaned_rating_gain_each_day[Global.day]
	Events.alert_posted.emit("+%s⭐ Spill cleaned!" % rating_gained, UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_GREEN)
	Global.employee_rating += rating_gained


func refill() -> void:
	Global.holding_ingredients = false
	Events.ingredients_bag_consumed.emit()

	Events.minigame_active.emit(REFILL_MINIGAME)

	await Events.minigame_end

	var ingredient_multiplier: float = 1.0
	for item in Global.owned_items:
		if item.item_id == "nice_spoon":
			if item.item_level == 1:
				ingredient_multiplier = 2.0
			elif item.item_level == 2:
				ingredient_multiplier = 3.0
	ingredients += roundi(Stats.current.ingredients_per_bag * Global.refill_minigame_accuracy * ingredient_multiplier)

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


func float_to_price(number: float) -> String:
	return ("$%.2f" % number).trim_suffix(".00")

func accept_order(did_remake_drink: bool) -> void:
	test_1 = 0
	test_2 = 0
	test_3 = 0

	gui_3d.exit_with_camera_tween()

	waiting_for_response = false
	Events.order_approved.emit(customer)

	order_breakdown.hide()

	var rating_before_update: float = Global.employee_rating

	if did_remake_drink:
		if order.star_rating_gain_for_remake > 0.0:
			Events.alert_posted.emit(
				"+%.1f Customer happy with drink!" % order.star_rating_gain_for_remake,
				UI.AlertIconType.RATING,
				4.0,
				UI.ALERT_COLOR_GREEN
			)
			Global.employee_rating += order.star_rating_gain_for_remake
	else:
		if order.star_rating_loss_if_accept > 0.0:
			Events.alert_posted.emit(
				"-%.1f Customer unhappy with drink..." % order.star_rating_loss_if_accept,
				UI.AlertIconType.RATING,
				4.0,
				UI.ALERT_COLOR_RED
			)
			Global.employee_rating -= order.star_rating_loss_if_accept

	# stagger showing the update popups for rating and money if both changed
	if Global.employee_rating != rating_before_update:
		await get_tree().create_timer(0.8, false).timeout

	Events.alert_posted.emit(
		"+%s Drink sold!" % float_to_price(order.final_order_price),
		UI.AlertIconType.MONEY,
		4.0,
		UI.ALERT_COLOR_MONEY
	)
	Global.daily_cafe_money += order.final_order_price

	# tippy will get mad if you're 40% or more under money goal and you only have 60 sec left
	if (
		Global.daily_cafe_money <= (Stats.current.daily_profit_goals_each_day[Global.day] * 0.6)
		and Global.shift_time_remaining <= 60.0
	):
		await get_tree().create_timer(0.8, false).timeout
		Events.under_money_goal.emit()

	await get_tree().create_timer(1.5, false).timeout
	customer.leave_store()
	_set_customer(null)


func reject_order() -> void:
	gui_3d.exit_with_camera_tween()

	# TODO: check if this can happen
	if ingredients < Stats.current.ingredients_per_order:
		return

	waiting_for_response = false

	machine_make_drink()


func break_down() -> void:
	if broken_down:
		return
	broken_down = true
	breakdown_timer.start()
	await breakdown_timer.timeout
	Global.player.camera.camera_effects.trigger_shake()

	if gui_3d.player_using_me:
		gui_3d.exit_with_camera_tween()
	gui_3d.interactable.visible = false
	ordered_drink_name_label.hide()
	fix_machine_button.show()
	breakdown_sound.play()
	Events.alert_posted.emit("A machine has broken down!", UI.AlertIconType.MACHINE, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
	Global.breakdowns_this_shift += 1

	timer.paused = true

	hum_sound.stop()


func on_active_item_used_fix_machine(item: Item):
	if item == null:
		return

	if item.item_id == "hammer":
		Events.play_viewmodel_animation.emit("hammer_use")
		Global.put_active_item_on_cooldown(item)
		await Events.hammer_animation_hit
		fix_machine(true)


func on_active_item_used(item: Item):
	if item == null:
		return

	if item.item_id == "airhorn":
		if customer:
			airhorn_sound.play()
			customer.leave_store()
			_set_customer(null)
			waiting_for_response = false
			order_breakdown.hide()

			Global.put_active_item_on_cooldown(item)


func _on_clean_spill() -> void:
	Events.minigame_active.emit(CLEAN_SPILL_MINIGAME)
	Events.minigame_end.connect(clean_up_spill)
	Events.minigame_cancelled.connect(cancel_clean_spill)


func _on_fix_machine_button_pressed() -> void:
	# we connect and disconnect these signals here instead of in _ready() so other machines dont get
	# the signal and do unintended things
	Events.minigame_end.connect(_on_machine_fixed)
	Events.minigame_cancelled.connect(cancel_fix_minigame)
	Events.minigame_active.emit(REPAIR_MINIGAMES.pick_random())


func _on_machine_fixed() -> void:
	Events.minigame_end.disconnect(_on_machine_fixed)
	Events.minigame_cancelled.disconnect(cancel_fix_minigame)
	fix_machine()


func _on_remake_drink_button_pressed() -> void:
	if ingredients < Stats.current.ingredients_per_order:
		no_ingredients_warning.show()
		await get_tree().create_timer(0.5, false).timeout
		no_ingredients_warning.hide()

	Events.minigame_end.connect(_on_remade_drink)
	Events.minigame_cancelled.connect(_cancel_remake_minigame)
	Events.force_close_minigame.connect(_on_force_close_minigame)
	Global.ordered_drink_to_remake = order.ordered_drink
	Global.ordered_drink_customer = customer
	Events.minigame_active.emit(MANUAL_DRINK_MINIGAMES.pick_random())
	Events.order_remaking_drink.emit()

	Global.tutorial_remake_button_pressed = true

	for item in Global.owned_items:
		if item.item_id == "barista_guide":
			var time_scale: float = 1.0
			if item.item_level == 1:
				time_scale = 0.5
			elif item.item_level == 2:
				time_scale = 0.25
			Engine.time_scale *= time_scale
			print("time scale set to: %s" % Engine.time_scale)


func _on_remade_drink() -> void:
	Events.minigame_end.disconnect(_on_remade_drink)
	Events.minigame_cancelled.disconnect(_cancel_remake_minigame)
	Events.force_close_minigame.disconnect(_on_force_close_minigame)

	gui_3d.exit_with_camera_tween()

	# TODO: check if this can happen
	if ingredients < Stats.current.ingredients_per_order:
		return

	consume_ingredients()

	order.made_drink = order.ordered_drink
	made_drink_name_label.text = (
			"you made:\n %s (%s)"
			% [order.made_drink.name, Global.float_to_price(order.final_order_price)]
	)
	display_drink_score()

	Global.tutorial_drink_remade = true
	Events.order_completed.emit(customer)
	customer.timer.stop()
	waiting_for_response = false

	accept_order(true)

	for item in Global.owned_items:
		if item.item_id == "barista_guide":
			Engine.time_scale = 1.0
			print("time scale returned to: %s" % Engine.time_scale)


func _cancel_remake_minigame() -> void:
	Events.minigame_end.disconnect(_on_remade_drink)
	Events.minigame_cancelled.disconnect(_cancel_remake_minigame)
	Events.force_close_minigame.disconnect(_on_force_close_minigame)

	for item in Global.owned_items:
		if item.item_id == "barista_guide":
			Engine.time_scale = 1.0
			print("time scale returned to: %s" % Engine.time_scale)


func _on_force_close_minigame() -> void:
	Events.minigame_end.disconnect(_on_remade_drink)
	Events.minigame_cancelled.disconnect(_cancel_remake_minigame)
	Events.force_close_minigame.disconnect(_on_force_close_minigame)

	for item in Global.owned_items:
		if item.item_id == "barista_guide":
			Engine.time_scale = 1.0
			print("time scale returned to: %s" % Engine.time_scale)


class OrderData:
	var ordered_drink: Drink
	var made_drink: Drink
	var main_correct: bool = false
	var liquid_correct: bool = false
	var extra_correct: bool = false
	var star_rating_gain_for_remake: float
	var star_rating_loss_if_accept: float
	var final_order_price: float
