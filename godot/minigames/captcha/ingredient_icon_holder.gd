class_name IngredientIconHolder
extends Control

@export var icon: TextureRect
@export var button: Button
@export var button_disabled: bool
@export var bg:TextureRect
var ignore_hover:bool = false

var ingredient: Ingredient = null:
	set(value):
		if value == null:
			ingredient = null
			icon.texture = null
		else:
			ingredient = value
			icon.texture = ingredient.icon


func _ready() -> void:
	button.disabled = button_disabled


func _on_button_toggled(toggled_on: bool) -> void:
	offset_transform_scale = Vector2(1,1)
	ignore_hover = true
	bg.self_modulate = Color.YELLOW if toggled_on else Color.WHITE
	var tween:Tween = create_tween()
	tween.tween_property(self,"offset_transform_scale",Vector2(0.7,0.7),0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(
		func():
			var tween2:Tween = create_tween()
			tween2.tween_property(self,"offset_transform_scale",Vector2.ONE,0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween2.tween_callback(
				func():
					ignore_hover = false
			)
	)


func _on_button_mouse_entered() -> void:
	if ignore_hover: return
	var tween:Tween = create_tween()
	tween.tween_property(self,"offset_transform_scale",Vector2(1.2,1.2),0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)


func _on_button_mouse_exited() -> void:
	if ignore_hover: return
	var tween:Tween = create_tween()
	tween.tween_property(self,"offset_transform_scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
