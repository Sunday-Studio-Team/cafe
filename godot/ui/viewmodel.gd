extends CanvasLayer

@export var sprite: AnimatedSprite2D
@export var hammer_item: Item


func _ready():
	Events.play_viewmodel_animation.connect(sprite.play)

	sprite.animation_finished.connect(
		func():
			_on_animation_finished()
			Events.viewmodel_animation_finished.emit()
	)

	sprite.play("default")


func _physics_process(_delta: float) -> void:
	if (
			sprite.frame == 21
			and sprite.animation == "hammer_use"
	):
		Events.hammer_animation_hit.emit()

	if (
			sprite.frame == 10
			and sprite.animation == "bag_pickup"
	):
		Events.bag_pickup_animation_grabbed.emit()

	visible = not Global.in_ui


func _on_animation_finished():
	match sprite.animation:
		"bag_pickup":
			if not Global.equipped_item:
				sprite.play("default")
			elif Global.equipped_item == hammer_item:
				sprite.play("hammer_idle")
		"hammer_use":
			sprite.play("default")
		"hammer_equip":
			sprite.play("hammer_idle")
