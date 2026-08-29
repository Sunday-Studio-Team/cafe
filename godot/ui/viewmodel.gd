extends CanvasLayer

@export var sprite: AnimatedSprite2D
@export var hammer_item: Item


func _ready() -> void:
	Events.play_viewmodel_animation.connect(sprite.play)

	# here we make sure if we just sold an item we stop showing the animation
	# of us holding it
	# (probably a smarter way to do this but i'll just hardcode here for now)
	#	- jack
	Events.items_updated.connect(
		func():
			if (
					sprite.animation == "hammer_idle"
					and not Global.owned_items.has(hammer_item)
			):
				sprite.play("default")
	)

	sprite.frame_changed.connect(_on_frame_changed)

	sprite.animation_finished.connect(
		func():
			_on_animation_finished()
			Events.viewmodel_animation_finished.emit()
	)

	sprite.play("default")


func _process(_delta: float) -> void:
	visible = not Global.in_ui


func _on_frame_changed() -> void:
	if (
			sprite.frame == 21
			and sprite.animation == "hammer_use"
	):
		Events.hammer_animation_hit.emit()
	elif (
			sprite.frame == 10
			and sprite.animation == "bag_pickup"
	):
		Events.bag_pickup_animation_grabbed.emit()
		Events.trash_pickup_animation_grabbed.emit()


func _on_animation_finished() -> void:
	match sprite.animation:
		"bag_pickup":
			if Global.equipped_item == hammer_item:
				sprite.play("hammer_idle")
			else:
				sprite.play("default")
		"hammer_use":
			sprite.play("default")
		"hammer_equip":
			sprite.play("hammer_idle")
