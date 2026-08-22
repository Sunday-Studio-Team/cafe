@tool
class_name MachineFixButton
extends MarginContainer

@export var color:Color

@export var letter_color:Color

@export var button:TextureButton
@export var button_texture:Texture2D


@export var letter_color_rect: ColorRect


func _ready() -> void:
	button.button_down.connect(func():modulate = Color.DIM_GRAY)
func _process(delta: float) -> void:
	button.texture_normal = button_texture
	letter_color_rect.color = letter_color
	button.self_modulate = color
	
	
	


func _on_button_mouse_entered() -> void:
	modulate = Color.DARK_GRAY


func _on_button_mouse_exited() -> void:
	modulate = Color.WHITE
