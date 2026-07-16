# basically just handles the commands and settings for the console
# (might be better as just part of Console or somewhere else
# (or maybe theres no real reason to put all these commands in the same script tbh)
# lemme know)
extends Node


func _ready() -> void:
	# NOTE: untested
	if not OS.has_feature("debug"):
		Console.enabled = false

	# not sure whether to enable this or not, seems to break some stuff
	# but might be better than accidentally pressing stuff in game by typing lol
	#Console.pause_enabled = true
	Console.font_size = 28
	# dont think we need this yet, but if the commands list gets much longer itll go offscreen
	#Console.toggle_size() # set fullscreen

	# NOTE: theres a command which shows a command list but it seems to include builtin ones,
	# so i think dumping this should help make this more friendly
	Console.print_line(
		"\n[b]COMMANDS[/b]
- [i]startshift[/i] starts shift
- [i]bank[/i] adds $100 to bank
- [i]break[/i] makes a random machine break
- [i]spill[/i] makes a random machine spill",
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

	# WARNING: dont really know how to get params to work yet lol
	#Console.add_command("item", give_item, ["item name"])
	#Console.add_command_autocomplete_list("item", Global.items)

	#Console.add_command("speed", set_speed, 1)


func set_speed(speed: float) -> void:
	Engine.time_scale = speed
	Console.print_line("game speed set to %s" % speed)


func start_shift() -> void:
	Events.shift_started.emit()
	Console.print_line("starting shift")


func give_item(item: Item) -> void:
	Global.owned_items.append(item)
	Console.print_line("gave %s" % item.name)


func bank() -> void:
	Global.bank_money = 100
	Console.print_line("added $100 to bank balance")


func breakdown() -> void:
	Global.machines.pick_random().break_down()
	Console.print_line("triggering breakdown on random machine")


func spill() -> void:
	Global.machines.pick_random().spill()
	Console.print_line("triggering spill on random machine")
