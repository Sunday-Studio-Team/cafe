# basically just handles the commands and settings for the console
# (might be better as just part of Console or somewhere else
# (or maybe theres no real reason to put all these commands in the same script tbh)
# lemme know)
extends Node

var _item_ids: Array[String] = []
var _shift_names: Array[String] = []
# tracks whether we have the 'unlimited actives' command toggled on
# (so we can toggle on/off with the same command)
var ua_enabled := false


func _ready() -> void:
	# NOTE: untested
	if not OS.has_feature("debug"):
		Console.enabled = false

	# not sure whether to enable this or not, seems to break some stuff
	# but might be better than accidentally pressing stuff in game by typing lol
	#Console.pause_enabled = true
	Console.font_size = 28
	Console.toggle_size() # set fullscreen

	var items_guide_str: String = "Available items: "
	for item in Global.items:
		items_guide_str += "\"%s\", " % item.item_id
	
	var shift_guide_str: String = "Available shifts: "
	for each_shift in Global.special_shifts:
		shift_guide_str += "\"%s\", " % each_shift.name

	# NOTE: theres a command which shows a command list but it seems to include builtin ones,
	# so i think dumping this should help make this more friendly
	Console.print_line(
		"\n[b]COMMANDS[/b]
- [i]startshift[/i] starts shift
- [i]endshift[/i] ends shift
- [i]endshift W[/i] forces a win
- [i]endshift L[/i] forces a loss
- [i]timer[/i] pauses the game timer (use again to resume)
- [i]profit <number>[/i] sets your daily profit
- [i]rating <number>[/i] sets your employee rating
- [i]bank[/i] adds $100 to bank
- [i]break[/i] makes a random machine break
- [i]spill[/i] makes a random machine spill
- [i]day <number>[/i] skips to a day and resets the game
- [i]item \"<item_id>\"[/i] gives you a specified item (TAB to auto-complete)
%s
- [i]shift \"<shift name>\"[/i] change to the spcial shift (TAB to auto-complete, can't be used after the shift has started)
%s
- [i]fullshelf[/i] gives you a full inventory of items
- [i]speed <number>[/i] sets the game speed
- [i]bag[/i] gives you an ingredients bag
- [i]ua[/i] (short for Unlimited Actives) gives active items back shortly after you use them (possibly buggy)"
		% [items_guide_str, shift_guide_str],
	)
	Console.print_line(
		"\n[color=green]tip: try typing the start of a command and pressing TAB to autofill ![/color]",
	)
	Console.print_line(
		"\n[color=gold](plz let us know what other commands you would find useful :D)
(or tell us if any of the existing ones seem bugged D:)[/color]",
	)

	Console.add_command("startshift", start_shift)
	Console.add_command("bank", bank)
	Console.add_command("break", breakdown)
	Console.add_command("spill", spill)
	Console.add_command("day", set_day, 1)
	Console.add_command("endshift", end_shift, ["arg"])
	Console.add_command("profit", set_profit, 1)
	Console.add_command("rating", set_rating, 1)
	Console.add_command("timer", toggle_timer)
	Console.add_command("fullshelf", fill_items)
	Console.add_command("bag", give_bag)
	Console.add_command("item", give_item, ["item_id"])
	for item in Global.items:
		_item_ids.append("\"%s\"" % item.item_id)
	Console.add_command_autocomplete_list("item", _item_ids)
	Console.add_command("speed", set_speed, 1)
	Console.add_command("ua", toggle_unlimited_actives)
	Console.add_command("shift", special_shift, ["shift_name"])
	for shift in Global.special_shifts:
		_shift_names.append("\"%s\"" % shift.name)
	Console.add_command_autocomplete_list("shift", _shift_names)

	Events.main_scene_loaded.connect(
		func():
			if ua_enabled and not Events.active_item_used.is_connected(refresh_active_item):
				Events.active_item_used.connect(refresh_active_item)
	)


func give_bag() -> void:
	Global.holding_ingredients = true
	Console.print_line("gave bag")


func fill_items() -> void:
	for i in Global.item_slots_amount:
		give_item(Global.items[i].name)


func set_profit(profit: String) -> void:
	Global.daily_cafe_money = float(profit)
	Console.print_line("setting profit to %s" % profit)


func set_rating(rating: String) -> void:
	Global.employee_rating = rating as float
	Console.print_line("setting rating to %s" % rating)
	if int(rating) > 5.0:
		Console.print_line("(will be clamped to limit of 5 stars")


func end_shift(arg: String = "") -> void:
	var detail := ""

	if arg.to_lower() == "w":
		Global.daily_cafe_money = 100
		Global.employee_rating = 100
		detail = "(forcing win)"
	elif arg.to_lower() == "l":
		Global.daily_cafe_money = 0
		Global.employee_rating = 0
		detail = "(forcing loss)"

	# unsafe ref but whatever
	Global.main_scene._on_game_timer_timeout()
	Console.print_line("ending shift %s" % detail)


func set_day(day: String) -> void:
	var final_day := Global.final_day
	if int(day) > final_day:
		Console.print_error("final day is day %s, can't set day higher than that :p" % final_day)
		return

	Global.day = int(day)
	Events.scene_switch_requested.emit(SceneSwitcher.GameScene.MAIN_SCENE)
	Console.print_line("skipping to day %s" % day)


func set_speed(param1: String) -> void:
	var speed: float = float(param1)
	Engine.time_scale = speed
	Console.print_line("game speed set to %s" % speed)


func start_shift() -> void:
	Events.shift_started.emit()
	Console.print_line("starting shift")


func give_item(item_id: String) -> void:
	for item in Global.items:
		if item_id == item.item_id:
			Global.owned_items.append(item)
			item.apply_stats()
			Events.items_updated.emit()
			Console.print_line("gave %s" % item.item_id)
			return
	Console.print_error("Item ID not found.")


func bank() -> void:
	Global.player_tips_bank = 100
	Console.print_line("added $100 to bank balance")


func breakdown() -> void:
	var all_machines_broken_down := true

	for m in Global.machines:
		if not m.broken_down:
			all_machines_broken_down = false
			break

	if all_machines_broken_down:
		Console.print_error("all machines already broken down")
		return

	var random_machine: Machine = null
	while random_machine == null or random_machine.broken_down:
		random_machine = Global.machines.pick_random()
	random_machine.break_down()
	Console.print_line("triggering breakdown on random machine")


func spill() -> void:
	Global.machines.pick_random().spill()
	Console.print_line("triggering spill on random machine")


func toggle_timer() -> void:
	var timer: Timer = Global.main_scene.game_timer

	if timer.is_stopped():
		Console.print_error("shift not in progress, can't toggle timer")
		return

	timer.paused = !timer.paused

	if timer.paused:
		Console.print_line("game timer paused")
	else:
		Console.print_line("game timer resumed")


func toggle_unlimited_actives() -> void:
	ua_enabled = !ua_enabled

	if ua_enabled:
		Events.active_item_used.connect(refresh_active_item)
		Console.print_line("Unlimited Actives enabled")
	else:
		Events.active_item_used.disconnect(refresh_active_item)
		Console.print_line("Unlimited Actives disabled")


func refresh_active_item(item: Item):
	# some items like the hammer wait for certain signals with their
	# animations etc before being disabled and handling all those cases
	# would be annoying/would break with new items so im just doing
	# a lazy timer which should cover most things
	await get_tree().create_timer(3, false).timeout
	item.can_be_used = true
	Events.items_updated.emit()


func special_shift(shift_name: String):
	if Global.shift_started:
		Console.print_line("You can't change shift after the shift has started! Try to use day # to restart today.")
		return
	Global.current_special_shift.unapply_stats()
	for shift in Global.special_shifts:
		if shift.name == shift_name:
			Global.current_special_shift = shift
			if Global.current_special_shift != null && Global.current_special_shift.name != "Normal":
				Global.popups["special shift"].open()
			return
	Console.print_line("Matching shift name not found; please check the spelling.")
