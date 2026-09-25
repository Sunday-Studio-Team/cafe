extends CanvasLayer

@export var sprite: AnimatedSprite2D
@export var hammer_item: Item

@export var _default_hand_animation_sprite_frames_uid: StringName
@export var _bag_pickup_hand_animation_sprite_frames_uid: StringName
@export var _air_horn_use_hand_animation_sprite_frames_uid: StringName
@export var _cream_use_hand_animation_sprite_frames_uid: StringName
@export var _hammer_use_hand_animation_sprite_frames_uid: StringName

var _sprite_frames_always_cache_tokens: Array[ResourceBackgroundLoaderToken] = []
var _sprite_frames_item_cache_tokens: Array[ResourceBackgroundLoaderToken] = []


func _ready() -> void:
	Events.items_updated.connect(_on_items_updated)
	
	Events.play_viewmodel_animation.connect(_on_play_viewmodel_animation)

	sprite.frame_changed.connect(_on_frame_changed)

	sprite.animation_finished.connect(
		func():
			_on_animation_finished()
			Events.viewmodel_animation_finished.emit(),
	)

	_cache_always_resources()
	
	_play_animation("default")
	

func _exit_tree() -> void:
	_uncache_item_resources()
	_uncache_always_resources()


func _process(_delta: float) -> void:
	visible = not Global.in_ui
	

func _on_play_viewmodel_animation(animation_name: String) -> void:
	_play_animation(animation_name)


func _on_items_updated() -> void:
	_uncache_item_resources()
	
	# Cache new stuff.
	var resource_background_loader: ResourceBackgroundLoader = Global.resource_background_loader
	var token: ResourceBackgroundLoaderToken
	for owned_item in Global.owned_items:
		if owned_item.item_id == "air_horn":
			token = resource_background_loader.cache_resource(_air_horn_use_hand_animation_sprite_frames_uid)
			_sprite_frames_item_cache_tokens.append(token)
		elif owned_item.item_id == "whipped_cream":
			token = resource_background_loader.cache_resource(_cream_use_hand_animation_sprite_frames_uid)
			_sprite_frames_item_cache_tokens.append(token)
		elif owned_item.item_id == "hammer":
			token = resource_background_loader.cache_resource(_hammer_use_hand_animation_sprite_frames_uid)
			_sprite_frames_item_cache_tokens.append(token)


func _on_frame_changed() -> void:
	if sprite.animation == "bag_pickup" and not Global.holding_ingredients and not Global.holding_trash:
		_play_animation("default")
	elif sprite.frame == 42 and sprite.animation == "hammer_use":
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
	elif animation_name == "bag_pickup":
		sprite_frames_uid = _bag_pickup_hand_animation_sprite_frames_uid
	elif animation_name == "airhorn_use":
		sprite_frames_uid = _air_horn_use_hand_animation_sprite_frames_uid
	elif animation_name == "cream_use":
		sprite_frames_uid = _cream_use_hand_animation_sprite_frames_uid
	elif animation_name == "hammer_use":
		sprite_frames_uid = _hammer_use_hand_animation_sprite_frames_uid

	var token: ResourceBackgroundLoaderToken
	for cache_token: ResourceBackgroundLoaderToken in _sprite_frames_always_cache_tokens:
		if cache_token.resource_uid == sprite_frames_uid:
			token = cache_token
			break
	if token == null:
		for cache_token: ResourceBackgroundLoaderToken in _sprite_frames_item_cache_tokens:
			if cache_token.resource_uid == sprite_frames_uid:
				token = cache_token
				break
	
	if token == null:
		printerr("view_model.gd: Requested spriteframes aren't cached!")
		return
	
	var sprite_frames: SpriteFrames = Global.resource_background_loader.get_resource(token)
	sprite.sprite_frames = sprite_frames
	sprite.play(animation_name)


func _cache_always_resources() -> void:
	# Always cache the default and bag pickup sprite frames
	var resource_background_loader: ResourceBackgroundLoader = Global.resource_background_loader
	var token: ResourceBackgroundLoaderToken
	token = resource_background_loader.cache_resource(_default_hand_animation_sprite_frames_uid)
	_sprite_frames_always_cache_tokens.append(token)
	token = resource_background_loader.cache_resource(_bag_pickup_hand_animation_sprite_frames_uid)
	_sprite_frames_always_cache_tokens.append(token)


func _uncache_always_resources() -> void:
	# Uncache previously cached stuff.
	var resource_background_loader: ResourceBackgroundLoader = Global.resource_background_loader
	for token in _sprite_frames_always_cache_tokens:
		resource_background_loader.uncache_resource(token)
	_sprite_frames_always_cache_tokens.clear()


func _uncache_item_resources() -> void:
	# Uncache previously cached stuff.
	var resource_background_loader: ResourceBackgroundLoader = Global.resource_background_loader
	for token in _sprite_frames_item_cache_tokens:
		resource_background_loader.uncache_resource(token)
	_sprite_frames_item_cache_tokens.clear()
