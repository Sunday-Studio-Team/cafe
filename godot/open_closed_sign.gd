extends Interactable

@export var important_emails_required_model: Node3D

func _ready() -> void:
	if EmailsManager.get_instance().has_unfinished_important_emails_to_date():
		enabled = false
		important_emails_required_model.visible = true
		Events.finished_important_email.connect(_on_finished_important_email)
	else:
		important_emails_required_model.visible = false
		enabled = true

func _on_interacted() -> void:
	super()
	print("Shift started!")
	enabled = false
	Events.shift_started.emit()

func _on_finished_important_email(email_data: EmailData) -> void:
	if EmailsManager.get_instance().has_unfinished_important_emails_to_date():
		return
	
	enabled = true
	important_emails_required_model.visible = false
	Events.finished_important_email.disconnect(_on_finished_important_email)		
	print("Start Shift sign enabled.")
