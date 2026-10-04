extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var has_frozen_tippy_item: bool = Global.owned_items.any(
			func(item: Item) -> bool:
				return item.item_id == "barista_guide"
	)
	
	if has_frozen_tippy_item:
		var spawn_animation_tween := create_tween().set_ignore_time_scale().set_trans(Tween.TRANS_SPRING)
		spawn_animation_tween.tween_property(
				self, 
				"offset_transform_scale", 
				Vector2.ONE, 
				0.5
		).from(Vector2.ZERO)
		await spawn_animation_tween.finished
		
		var rotate_tween := create_tween().set_loops().set_ignore_time_scale()
		rotate_tween.tween_property(
				self, 
				"offset_transform_rotation", 
				deg_to_rad(5), 
				0.1
		)
		rotate_tween.tween_interval(1.5)
		rotate_tween.tween_callback(play_shake_animation)
		rotate_tween.tween_property(
				self,
				"offset_transform_rotation",
				deg_to_rad(-5),
				0.1
		)
		rotate_tween.tween_interval(1.5)
		rotate_tween.tween_callback(play_shake_animation)
	else:
		hide()


func play_shake_animation() -> void:
	var shake_horizontal_tween := create_tween().set_ignore_time_scale()
	shake_horizontal_tween.tween_property(
			self, 
			"offset_transform_position_ratio:x", 
			0.05, 
			0.1
	)
	shake_horizontal_tween.tween_property(
			self,
			"offset_transform_position_ratio:x",
			-0.05,
			0.1
	)
	shake_horizontal_tween.tween_property(
			self,
			"offset_transform_position_ratio:x",
			0,
			0.1
	)

	var shake_vertical_tween := create_tween().set_ignore_time_scale()
	shake_vertical_tween.tween_property(
			self,
			"offset_transform_position_ratio:y",
			0.01,
			0.1
	)
	shake_vertical_tween.tween_property(
			self,
			"offset_transform_position_ratio:y",
			-0.01,
			0.1
	)
	shake_vertical_tween.tween_property(
			self,
			"offset_transform_position_ratio:y",
			0,
			0.1
	)

	var grow_tween := create_tween().set_ignore_time_scale()
	grow_tween.tween_property(
			self, 
			"offset_transform_scale", 
			Vector2.ONE * 1.1, 
			0.25
	)
	grow_tween.tween_property(
			self, 
			"offset_transform_scale", 
			Vector2.ONE, 
			0.25
	)
	
	var blue_tint_tween := create_tween().set_ignore_time_scale()
	blue_tint_tween.tween_property(self, 
			"modulate", 
			Color.CYAN, 
			0.1
	)
	blue_tint_tween.tween_property(self,
			"modulate",
			Color.WHITE,
			0.25
	)
	
