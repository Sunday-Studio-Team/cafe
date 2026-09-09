extends Control


func _ready() -> void:
	for child in get_children():
		if child is TextureButton and child.texture_normal:
			var image = child.texture_normal.get_image()
			var bitmap = BitMap.new()
			# assign alpha channel as mask so that overalapping
			# rects from other rightly placed buttons do not block
			# button presses
			bitmap.create_from_image_alpha(image)
			child.texture_click_mask = bitmap
