extends PanelContainer

@export var machines_container: Container
@export var machine_ui_scene: PackedScene
@export var item_icons: Control


func _ready() -> void:
	await get_tree().process_frame
	populate_ui()
	populate_items()
	Events.items_updated.connect(populate_items)


func _physics_process(_delta: float) -> void:
	visible = (
			not Global.in_ui
			or Global.in_machine_ui
			or Global.showing_floating_cursor
	)


func populate_items() -> void:
	var i := 0
	for icon: TabletItemIcon in item_icons.get_children():
		if Global.owned_items.size() >= i + 1:
			icon.item = Global.owned_items[i]
		else:
			icon.item = null
		i += 1


func populate_ui() -> void:
	for m in Global.machines:
		var machine_ui: TabletMachineUI = machine_ui_scene.instantiate()
		machine_ui.machine = m
		machines_container.add_child(machine_ui)
