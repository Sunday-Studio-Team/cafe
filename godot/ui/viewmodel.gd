extends CanvasLayer

@export var sprite: AnimatedSprite2D
@export var hammer_item: Item

@export var _default_hand_animation_sprite_frames_uid: StringName
@export var _air_horn_use_hand_animation_sprite_frames_uid: StringName
@export var _bag_pickup_hand_animation_sprite_frames_uid: StringName
@export var _cream_use_hand_animation_sprite_frames_uid: StringName
@export var _hammer_use_hand_animation_sprite_frames_uid: StringName


func _ready() -> void:
	Events.play_viewmodel_animation.connect(_on_play_viewmodel_animation)

	sprite.frame_changed.connect(_on_frame_changed)

	sprite.animation_finished.connect(
		func():
			_on_animation_finished()
			Events.viewmodel_animation_finished.emit(),
	)

	_play_animation("default")


func _process(_delta: float) -> void:
	visible = not Global.in_ui
	

func _on_play_viewmodel_animation(animation_name: String) -> void:
	_play_animation(animation_name)
	

func _on_frame_changed() -> void:
	if sprite.animation == "bag_pickup" and not Global.holding_ingredients and not Global.holding_trash:
		_play_animation("default")
	elif sprite.frame == 21 and sprite.animation == "hammer_use":
		Events.hammer_animation_hit.emit()
	elif sprite.frame == 7 and sprite.animation == "bag_pickup":
		Events.bag_pickup_animation_grabbed.emit()
		Events.trash_pickup_animation_grabbed.emit()
	elif sprite.frame == 13 and sprite.animation == "airhorn_use":
		Events.air_horn_animation_just_blasted.emit()
	elif sprite.frame == 5 and sprite.animation == "cream_use":
		Events.whipped_cream_animation_shot.emit()


func _on_animation_finished() -> void:
	match sprite.animation:
		"bag_pickup":
			_play_animation("default")
		"hammer_use":
			_play_animation("default")
		_:
			_play_animation("default")

func _play_animation(animation_name: String) -> void:
	var sprite_frames_uid: StringName
	if animation_name == "default":
		sprite_frames_uid = _default_hand_animation_sprite_frames_uid
	elif animation_name == "airhorn_use":
		sprite_frames_uid = _air_horn_use_hand_animation_sprite_frames_uid
	elif animation_name == "bag_pickup":
		sprite_frames_uid = _bag_pickup_hand_animation_sprite_frames_uid
	elif animation_name == "cream_use":
		sprite_frames_uid = _cream_use_hand_animation_sprite_frames_uid
	elif animation_name == "hammer_use":
		sprite_frames_uid = _hammer_use_hand_animation_sprite_frames_uid

	var sprite_frames: SpriteFrames = ResourceLoader.load(sprite_frames_uid)
	sprite.sprite_frames = sprite_frames
	sprite.play(animation_name)
