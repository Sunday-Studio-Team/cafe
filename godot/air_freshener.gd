class_name AirFreshener
extends Node3D

@export var _interactable: Interactable
@export var _cooldown_timer_sprite: Sprite3D
@export var _cooldown_timer_bar: TextureProgressBar
@export var _spray_sound: AudioStreamPlayer3D
@export var _collider_body: StaticBody3D

var _air_freshener_item_on_cooldown: Item = null

func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	_interactable.requested_use_active_item.connect(_on_requested_use_active_item)

	_cooldown_timer_sprite.visible = false

func _process(delta: float) -> void:
	if _air_freshener_item_on_cooldown != null:
		_cooldown_timer_bar.value = _air_freshener_item_on_cooldown.active_item_remaining_cooldown
		if _air_freshener_item_on_cooldown.can_be_used:
			_cooldown_timer_sprite.visible = false
			_air_freshener_item_on_cooldown = null

func enable_air_freshener() -> void:
	visible = true
	_interactable.visible = true
	_collider_body.process_mode = Node.PROCESS_MODE_INHERIT

func disable_air_freshener() -> void:
	visible = false
	_interactable.visible = false
	_collider_body.process_mode = Node.PROCESS_MODE_DISABLED

func _on_interacted() -> void:
	pass

func _on_requested_use_active_item() -> void:
	var air_freshener_item: Item = null
	for owned_item in Global.owned_items:
		if owned_item.item_id == "air_freshener":
			air_freshener_item = owned_item
			break

	if air_freshener_item == null or !air_freshener_item.can_be_used:
		return

	var customer_wait_duration_extension: float = 0.0
	if air_freshener_item.item_level == 1:
		customer_wait_duration_extension = 20.0
	else:
		customer_wait_duration_extension = 30.0

	_spray_sound.play()

	Global.main_scene.apply_used_air_freshener(customer_wait_duration_extension)
	Events.alert_posted.emit("+%ss to all customers' patience!" % customer_wait_duration_extension, UI.AlertIconType.CUSTOMER)
	Global.put_active_item_on_cooldown(air_freshener_item)

	# Track the air freshener item on cooldown
	_air_freshener_item_on_cooldown = air_freshener_item
	_cooldown_timer_sprite.visible = true
	_cooldown_timer_bar.max_value = _air_freshener_item_on_cooldown.active_item_remaining_cooldown
	_cooldown_timer_bar.value = _air_freshener_item_on_cooldown.active_item_remaining_cooldown
