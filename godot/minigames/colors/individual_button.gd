@tool
class_name MachineFixButton
extends MarginContainer

@export var color:Color

@export var letter:String
@export var letter_color:Color

@export var button:TextureButton



@export var color_rect: ColorRect
@export var rich_text_label: RichTextLabel


func _ready() -> void:
	pass
func _process(delta: float) -> void:
	color_rect.color = color
	rich_text_label.text = "[center][color=#%s][font_size=256]%s" % [letter_color.to_html(),letter]
	
