class_name ClickableLockerItem
extends Node3D

@export var item: Item
@export var prop_shower_hider: PropHider
@export var area: Area3D

var should_be_hidden = false
var hovered:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.mouse_entered.connect(on_hover)
	area.mouse_exited.connect(on_unhover)
	prop_shower_hider.prop_item = item


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = Global.unlocked_items.has(item) and not should_be_hidden

func on_hover():
	hovered = true

func on_unhover():
	hovered = false


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if hovered and event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = (event as InputEventMouseButton)
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Global.item_loadout_menu._on_available_item_pressed(item,self)
