extends MeshInstance3D

@export var machines_container: Container
@export var machine_ui_scene: PackedScene


func _ready() -> void:
	await get_tree().process_frame
	populate_ui()


func _physics_process(_delta: float) -> void:
	visible = not Global.in_ui


func populate_ui() -> void:
	for m in Global.machines:
		var machine_ui: TabletMachineUI = machine_ui_scene.instantiate()
		machine_ui.machine = m
		machines_container.add_child(machine_ui)
