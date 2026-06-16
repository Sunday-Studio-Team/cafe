class_name EmailApp
extends PCApp

@export var emails_schedule: Array[EmailData]
@export var email_app_list_item_packed_scene: PackedScene
@export var email_app_list_items_container: Node
@export var email_viewer: EmailViewer

func _ready() -> void:
	super()
	email_viewer.visible = false
	_populate_email_items()

func _populate_email_items() -> void:
	# Check current day
	var current_day: int = Global.day
	# Check save data for read emails
	var read_emails: Array[EmailData] = Global.read_emails
	
	# Check emails schedule for all emails that are current day or beyond
	var emails_to_populate: Array[EmailData] = []
	for email_data in emails_schedule:
		var email_scheduled_day: int = email_data.day_to_send
		if current_day >= email_scheduled_day:
			emails_to_populate.append(email_data)		
	
	# Create email list items, and mark read or unread
	for email_data in emails_to_populate:
		var is_email_read: bool = false
		if email_data in read_emails:
			is_email_read = true
	
		var is_current_day: bool = false
		if current_day == email_data.day_to_send:
			is_current_day = true
	
		var email_app_list_item: EmailAppListItem = email_app_list_item_packed_scene.instantiate()
		email_app_list_item.initialize(email_data, is_email_read, is_current_day) 
		email_app_list_items_container.add_child(email_app_list_item, true)
		email_app_list_items_container.move_child(email_app_list_item, 0)
		email_app_list_item.email_pressed.connect(_on_email_pressed)

func _on_email_pressed(email_app_list_item: EmailAppListItem) -> void:
	var email_data: EmailData = email_app_list_item.email_data
	# Mark as read if unread
	if not email_app_list_item.is_read:
		Global.read_emails.append(email_data)
		email_app_list_item.mark_as_read()
	# Open the email in the viewer
	_open_email_in_viewer(email_data)

func _open_email_in_viewer(email_data: EmailData) -> void:
	# Check current day
	var current_day: int = Global.day
	var is_current_day: bool = false
	if current_day == email_data.day_to_send:
		is_current_day = true
	
	email_viewer.visible = true
	email_viewer.show_email(email_data, is_current_day)
