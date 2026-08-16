# TODO: make the fixing minigame flow more readable
# machine_3d_gui.gd is where the player interacts with the machine
class_name Machine
extends Node3D

static var seen_breakdown_popup := false

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
@export var make_drink_button: Button
@export var accept_button: Button
@export var reject_button: Button
@export var refill_button: Button
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
@export var gui_3d: Gui3D
@export var customer_wait_indicator: Control
@export var customer_wait_bar: TextureProgressBar
@export var no_ingredients_warning: Control
@export var get_ingredients_prompt: Control
@export var time_bonus_panel: PanelContainer
@export var time_bonus_label: Label
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
@export var hum_sound: AudioStreamPlayer3D
@export var done_sound: AudioStreamPlayer3D
@export var spill_clean_sound: AudioStreamPlayer3D
@export var fixed_sound: AudioStreamPlayer3D
@export var spill_clean_particles: GPUParticles3D
@export var tip_label: Label
@export var hammer_item: Item
@export var scrubber_item: Item
@export var hammer_hit_sound: AudioStreamPlayer
@export var popup_storage_room: PackedScene # tutorial popup that tells player to go to the storage room
@export var popup_go_to_spill: PackedScene # tutorial popup that tells player to go to the spill

var customer: Customer
var queued_customer: Customer
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
var manual_drink_minigames := ["Captcha"]
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
	make_drink_button.button_down.connect(_on_remake_drink_button_pressed)
	reject_button.pressed.connect(
		func():
			if ingredients < Stats.current.ingredients_per_order:
				no_ingredients_warning.show()
				await get_tree().create_timer(0.5, false).timeout
				no_ingredients_warning.hide()
			else:
				reject_order()
	)
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

	breakdown_timer.wait_time = timer.wait_time / 2 + randf_range(-1, 1)

	Events.customer_approached_window.connect(_on_customer_approached_window)
	spill_interactable.interacted.connect(_on_clean_spill)

	progress_indicator.hide()
	price_label.hide()
	customer_order_indicator.hide()
	order_breakdown.hide()
	final_order_indicator.hide()

	# glowing fx on spill warning
	var t := create_tween().set_loops()
	t.tween_property(spill_warning, "modulate", Color.GOLD, 1)
	t.tween_property(spill_warning, "modulate", Color.RED, 1)

	#Active Items
	fix_machine_button.used_active_item.connect(on_active_item_used_machine)


func _process(_delta: float) -> void:
	progress_bar.value = (1 - timer.time_left / timer.wait_time) * 100

	progress_indicator.visible = not timer.is_stopped()

	accept_button.visible = waiting_for_response
	reject_button.visible = waiting_for_response
	make_drink_button.visible = waiting_for_response
	make_drink_button.disabled = ingredients < Stats.current.ingredients_per_order
	made_breakdown.visible = waiting_for_response
	made_drink_icon.visible = waiting_for_response

	ingredients_bar.value = ingredients
	if ingredients < Stats.current.ingredients_per_order:
		ing_too_low_label.show()
		ingredients_bar.modulate = Color.RED

		#shows tutorial (checks inside if it's appropriate to show)
		show_tutorial_where_is_storeroom()

	else:
		if ingredients <= max_ingredients / 2.0:
			ingredients_bar.modulate = Color.YELLOW
		else:
			ingredients_bar.modulate = Color.GREEN
		ing_too_low_label.hide()

	spill_warning.visible = spill_on_floor

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

	#if make_drink_button.held:
	#Global.holding_make_drink_button = true

static func set_next_drink_score(score: int) -> void:
	if !(score in Stats.current.score_chances.keys()):
		return

	for k in Stats.current.score_chances.keys():
		if k == score:
			Stats.current.score_chances[k] = 1.0
		else:
			Stats.current.score_chances[k] = 0.0


func show_tutorial_where_is_storeroom() -> void:
	#this is getting called within physics_process...
	#check values in global
	#and then immediately turn those values to 'tutorial has been shown',
	if OS.has_feature("skip_popups"):
		return

	if Global.tutorial_refill_shown == false:
		Global.tutorial_refill_shown = true
		
		while (Global.in_ui):
			await get_tree().create_timer(0.25).timeout
			#janky way to make sure the popup tutorial does not show up while in a menu/minigame
		
		await get_tree().create_timer(0.75).timeout # allows audio to play first
		
		Global.in_tutorial_screen = true

		#hide tablet so it's not in the way.
		var tablet = get_parent().get_parent().find_child("Tablet")
		tablet.hide()

		var popup = popup_storage_room.instantiate()
		add_child(popup)
		get_tree().paused = true # this kinda works but its janky
		var next_label = popup.get_node("NextButton/NextLabel")
		next_label.text = "Okay"

		var button = popup.get_node("NextButton")
		#button.move_to_front() #this was an attempt to fix issue, does not really do anything
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


func set_order_action_buttons_available(button_case: String) -> void:
	accept_button.disabled = true
	reject_button.disabled = true
	make_drink_button.disabled = true
	refill_button.disabled = true

	match button_case:
		"accept":
			accept_button.disabled = false
		"reject":
			reject_button.disabled = false
		"make_drink":
			make_drink_button.disabled = false
		"refill":
			refill_button.disabled = false
		"all":
			accept_button.disabled = false
			reject_button.disabled = false
			make_drink_button.disabled = false
			refill_button.disabled = false
		"none":
			pass
		_:
			print("invalid button_case passed to set_order_action_buttons_available()")


# called from inside spill() (so that itll still show if we trigger the spill
# via a console command etc
func show_tutorial_go_clean_spill() -> void:
	#this is called right after spill() is called [but not inside spill()]
	if OS.has_feature("skip_popups"):
		return

	while (Global.in_ui):
		await get_tree().create_timer(0.25).timeout
		#janky way to make sure the popup tutorial does not show up while in a menu/minigame

	await get_tree().create_timer(0.75).timeout # allows audio to play first
	if (Global.day == 1) and (Global.tutorial_go_clean_spill_shown == false):
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


func set_customer(c: Customer) -> void:
	customer = c
	if customer != null:
		await customer.move_to(spot_for_customer.global_position)

		if spill_on_floor:
			Global.score_update_message = "customer stepped in spill"
			Global.employee_rating -= Stats.current.penalty_for_customer_stood_in_spill

	else:
		customer_order_indicator.hide()
		final_order_indicator.hide()
		order_breakdown.hide()
		price_label.hide()
		drink_customer_score_label.hide()
		waiting_for_response = false
		timer.stop()
		if Global.making_drink_manually and gui_3d.player_using_me:
			# NOTE: not sure these are both correct + necessary to cancel a minigame
			# but this seems to behave correctly
			Events.force_close_minigame.emit()
			Events.minigame_cancelled.emit()
			# this might already get set somewhere else but just to be sure
			Global.making_drink_manually = false


func get_stats() -> void:
	# Deprecated with addition of ramking minigame, I think
	#make_drink_button.time_to_hold = Stats.current.time_to_manually_make_drink
	timer.wait_time = Stats.current.machine_time_to_make_drink


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

	hum_sound.pitch_scale = randf_range(0.95, 1.05)
	hum_sound.play()

	order = OrderData.new()
	order.ordered_drink = customer.desired_drink
	customer_order_indicator.text = (
			"ORDERED:\n %s (%s)"
			% [order.ordered_drink.name, Global.float_to_price(order.ordered_drink.price)]
	)

	ordered_main_ingredient_icon.texture = order.ordered_drink.main_ingredient.icon
	ordered_liquid_icon.texture = order.ordered_drink.liquid.icon
	if (order.ordered_drink.extra):
		ordered_extra_icon.texture = order.ordered_drink.extra.icon
	else:
		ordered_extra_icon.texture = null
	ordered_drink_icon.texture = order.ordered_drink.icon

	customer_order_indicator.show()
	order_breakdown.show()

	timer.start()

	if (
			randf() < Stats.current.chance_of_machine_breaking
			and Global.breakdowns_this_shift < Stats.current.max_breakdowns_per_shift
	):
		break_down()

	await timer.timeout

	hum_sound.stop()
	done_sound.play()

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
	randomize()
	Global.drinks.shuffle()
	for item in Global.drinks.filter(func(d: Drink): return d.is_unlocked()):
		var sc = item.get_score_from(order.ordered_drink)
		if sc == order.score:
			order.made_drink = item
			break
	
	if Global.current_special_shift != null and Global.current_special_shift.name == "Critical Customers":
		if order.score < 3:
			order.score = -3

	if !order.made_drink: # get a random drink, useful for earlier days
		order.made_drink = Global.drinks.filter(func(d: Drink): return d.is_unlocked()).pick_random()
		order.score = order.made_drink.get_score_from(order.ordered_drink)

	if order.ordered_drink.main_ingredient == order.made_drink.main_ingredient:
		order.main_correct = true
	if order.ordered_drink.liquid == order.made_drink.liquid:
		order.liquid_correct = true
	if order.ordered_drink.extra == order.made_drink.extra:
		order.extra_correct = true

	#completed_order = Global.full_wrong_drink # make every order fully wrong for testing

	display_drink_score()

	# TODO: move hardcoded tip chance here somewhere else
	tip_label.text = ""
	if tip_jar_item in Global.owned_items and randf() < 0.25:
		order.tip = randf_range(0.25, 1)
		tip_label.text = "(+ %s TIP)" % Global.float_to_price(order.tip)

	if (
			randf() < Stats.current.machine_chance_of_spill
			and Global.spills_this_shift < Stats.current.max_spills_per_shift
	):
		spill()

	final_order_indicator.text = (
			"MADE:\n %s (%s)"
			% [order.made_drink.name, Global.float_to_price(order.made_drink.price)]
	)
	final_order_indicator.show()

	waiting_for_response = true
	Events.order_completed.emit(customer)


# NOTE: separated into its own func so it can be called from dev console
func spill() -> void:
	spill_interactable.show()
	spill_sound.play()
	Events.alert_posted.emit("⚙️machine made a spill")
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
			customer_order_indicator.show()
			hum_sound.pitch_scale = randf_range(0.95, 1.05)
			hum_sound.play()
		elif waiting_for_response:
			return
		else:
			machine_make_drink()


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
	spill_clean_sound.play()
	spill_clean_particles.restart()


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
	final_order_indicator.text = "dispensing . . ."

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


func finished_make_drink_manually() -> void:
	gui_3d.exit()

	if ingredients < Stats.current.ingredients_per_order:
		return

	consume_ingredients()

	order.made_drink = order.ordered_drink
	order.score = 3
	final_order_indicator.text = (
			"you made:\n %s (%s)"
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
	if broken_down == true:
		return
	broken_down = true
	breakdown_timer.start()
	await breakdown_timer.timeout

	# Showing the popup tutorial when the machine is broken
	if not seen_breakdown_popup:
		seen_breakdown_popup = true # Only showing it once
		Global.popups["breakdown"].open()
	else:
		pass

	if gui_3d.player_using_me:
		gui_3d.exit()
	gui_3d.interactable.visible = false
	customer_order_indicator.hide()
	fix_machine_button.show()
	breakdown_sound.play()
	Events.alert_posted.emit("⚙️ machine broke down")
	Global.breakdowns_this_shift += 1

	timer.paused = true
	
	hum_sound.stop()


#Active Item
#If item used, checks if it's valid and does the specified action
func on_active_item_used_machine(item: Item):
	if item == null:
		return

	if item == hammer_item:
		Events.play_viewmodel_animation.emit("hammer_use")
		Global.deactivate_active_item(item)
		await Events.hammer_animation_hit
		fix_machine(true)


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


func _on_remake_drink_button_pressed() -> void:
	Events.minigame_end.connect(_on_remade_drink)
	Events.minigame_cancelled.connect(_cancel_remake_minigame)
	Global.ordered_drink_to_remake = order.ordered_drink
	Events.minigame_active.emit(manual_drink_minigames.pick_random())


func _on_remade_drink() -> void:
	Events.minigame_end.disconnect(_on_remade_drink)
	Events.minigame_cancelled.disconnect(_cancel_remake_minigame)
	finished_make_drink_manually()


func _cancel_remake_minigame() -> void:
	Events.minigame_end.disconnect(_on_remade_drink)
	Events.minigame_cancelled.disconnect(_cancel_remake_minigame)


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
