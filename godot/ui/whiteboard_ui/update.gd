@tool
extends HBoxContainer

@export var icon: TextureRect
@export var extra_overlay: TextureRect
@export var update_name: RichTextLabel
@export var extra_icon: TextureRect

@export_group("Details")
@export var icon_texture:Texture2D
@export var extra_overlay_texture:Texture2D
@export var extra_icon_texture:Texture2D
@export_multiline var text:String

@export_tool_button("Update Section")
var update_action:Callable = update_stuff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_stuff()

func update_stuff():
	icon.texture = icon_texture
	extra_overlay.texture = extra_overlay_texture
	update_name.text = text
	extra_icon.texture = extra_icon_texture
