extends Node3D

@export var interactable: Interactable
@export var important_emails_required_model: Node3D

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	
	if EmailsManager.get_instance().has_unfinished_important_emails_to_date():
		interactable.visible = false
		important_emails_required_model.visible = true
		Events.finished_important_email.connect(_on_finished_important_email)
	else:
		important_emails_required_model.visible = false
		interactable.visible = true

func _on_interacted() -> void:
	print("Shift started!")
	interactable.visible = false
	Events.shift_started.emit()

func _on_finished_important_email(email_data: EmailData) -> void:
	if EmailsManager.get_instance().has_unfinished_important_emails_to_date():
		return

	interactable.visible = true
	important_emails_required_model.visible = false
	Events.finished_important_email.disconnect(_on_finished_important_email)		
	print("Start Shift sign enabled.")
