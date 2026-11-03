class_name ClickableLockerItem
extends Node3D

@export var item: Item
@export var item3Ds: Array[MeshInstance3D]
@export var prop_shower_hider: PropHider
@export var area: Area3D

var material: ShaderMaterial
var should_be_hidden = false
var hovered:bool = false
var materials: Array[ShaderMaterial] = []

func _ready() -> void:
	area.mouse_entered.connect(on_hover)
	area.mouse_exited.connect(on_unhover)
	prop_shower_hider.prop_item = item
	
	#if item3D:
		#material = item3D.get_surface_override_material(0)
		#print("material from 3d itm is set")
	
	materials.clear()
	if item3Ds:
		for m in item3Ds:
			if m:
				var mat = m.get_surface_override_material(0) as ShaderMaterial
				materials.append(mat)

func _process(delta: float) -> void:
	visible = Global.unlocked_items.has(item) and not (should_be_hidden or Global.owned_items.has(item))
		
func on_hover():
	hovered = true
	print("hover")
	for mat in materials:
		mat.set_shader_parameter("u_hover", 1.0)

func on_unhover():
	hovered = false
	print("unhover")
	for mat in materials:
		mat.set_shader_parameter("u_hover", 0.0)


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if hovered and event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = (event as InputEventMouseButton)
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Global.item_loadout_menu._on_available_item_pressed(item,self)
