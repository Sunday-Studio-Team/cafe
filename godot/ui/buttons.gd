extends Control

@export var animated_sprite: AnimatedSprite2D
@export var button_container: Control

func _ready() -> void:
	if not animated_sprite or not button_container:
		return
		
	button_container.modulate.a = 0.0
	
	animated_sprite.play("menu")
	
	await animated_sprite.animation_finished
	
	await get_tree().create_timer(0.2).timeout
	
	var tween = create_tween()
	tween.tween_property(button_container, "modulate:a", 1.0, 1.0)
	
	for child in get_children():
		if child is TextureButton and child.texture_normal:
			var image = child.texture_normal.get_image()
			var bitmap = BitMap.new()
			# assign alpha channel as mask so that overalapping
			# rects from other rightly placed buttons do not block
			# button presses
			bitmap.create_from_image_alpha(image)
			child.texture_click_mask = bitmap
