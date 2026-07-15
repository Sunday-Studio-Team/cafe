# basically just handles the commands and settings for the console
# (might be better as just part of Console or somewhere else lemme know)
extends Node


func _ready() -> void:
	# NOTE: untested
	if not OS.has_feature("debug"):
		Console.enabled = false

	# not sure whether to enable this or not, seems to break some stuff
	# but might be better than accidentally pressing stuff in game by typing
	#Console.pause_enabled = true
	Console.font_size = 28

	Console.add_command("startshift", start_shift)
	Console.add_command("bank", bank)
	Console.add_command("break", breakdown)
	Console.add_command("spill", spill)

	# WARNING: doesnt really work yet
	Console.add_command("item", give_item, ["item name"])
	Console.add_command_autocomplete_list("item", Global.items)


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
