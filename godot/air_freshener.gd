class_name AirFreshener
extends Node3D

@export var _interactable: Interactable

func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	_interactable.requested_use_active_item.connect(_on_requested_use_active_item)

func enable_air_freshener() -> void:
	visible = true
	_interactable.visible = true

func disable_air_freshener() -> void:
	visible = false
	_interactable.visible = false

func _on_interacted() -> void:
	pass

func _on_requested_use_active_item() -> void:
	var air_freshener: Item = null
	for owned_item in Global.owned_items:
		if owned_item.item_id == "air_freshener":
			air_freshener = owned_item
			break

	if air_freshener == null or !air_freshener.can_be_used:
		return

	var customer_wait_duration_extension: float = 0.0
	if air_freshener.item_level == 1:
		customer_wait_duration_extension = 20.0
	else:
		customer_wait_duration_extension = 30.0

	Global.main_scene.apply_used_air_freshener(customer_wait_duration_extension)
	Events.alert_posted.emit("+%ss to all customers' patience!" % customer_wait_duration_extension, UI.AlertIconType.CUSTOMER)
	Global.put_active_item_on_cooldown(air_freshener)
