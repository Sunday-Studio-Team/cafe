class_name CustomerTrash
extends RigidBody3D

@export var interactable: Interactable

signal trash_bag_taken(customer_trash: CustomerTrash)
var rating_loss: float = 0.2

# just a thing to check so we cant spam interact and cause weird stuff with
# viewmodel animation
var already_interacted := false
var time_left_out: float = 0.0
var trash_timeout_threshold: float = 15.0


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	Global.total_trash += 1
	if Global.total_trash > 4:
		Global.employee_rating -= rating_loss
		Events.alert_posted.emit("-%s Too much trash in the store" % rating_loss, UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
	
	# briefly disable on spawn so if we're dropping it we cant accidentally
	# interact with it as it falls
	interactable.visible = false
	await get_tree().create_timer(0.5, false).timeout
	interactable.visible = true
	
func _on_interacted() -> void:
	if Global.holding_trash or already_interacted:
		return

	trash_bag_taken.emit(self)
	Global.holding_trash = true
	already_interacted = true
	Events.play_viewmodel_animation.emit("bag_pickup")
	
	# basically some weird stuff can happen if we throw the bag right after we
	# pick up, so we just get rid of it if something weird happened which
	# caused it to still be in the tree after a while
	var timer_to_delete_if_something_went_wrong := Timer.new()
	timer_to_delete_if_something_went_wrong.wait_time = 0.25
	timer_to_delete_if_something_went_wrong.timeout.connect(
		func():
			await create_tween().tween_property(self, "scale", Vector3.ZERO, 0.1).finished
			queue_free(),
	)
	add_child(timer_to_delete_if_something_went_wrong)
	timer_to_delete_if_something_went_wrong.start()
	
	await Events.trash_pickup_animation_grabbed
	queue_free()

func _process(delta:float) -> void:
	time_left_out += delta
	if time_left_out >= trash_timeout_threshold:
		Global.employee_rating -= (rating_loss * 2)
		Global.total_trash -= 1
		Events.alert_posted.emit("-%s Trash was left out too long..." % (rating_loss * 2), UI.AlertIconType.RATING, UI.ALERT_DEFUALT_DURATION, UI.ALERT_COLOR_RED)
		queue_free()
		
	
