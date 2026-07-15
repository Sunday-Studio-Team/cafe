class_name EmailApp
extends PCApp

@export var email_app_list_item_packed_scene: PackedScene
@export var email_app_list_items_container: Node
@export var email_viewer: EmailViewer

var email_app_list_items: Array[EmailAppListItem]

func _ready() -> void:
	super()
	
	email_viewer.visible = false
	_populate_email_items()
	
	Events.finished_important_email.connect(_on_finished_important_email)

func _populate_email_items() -> void:
	var emails_manager: EmailsManager = EmailsManager.get_instance()
	var emails_to_populate: Array[EmailData] = emails_manager.get_delivered_emails_to_date()

	# Check current day
	var current_day: int = Global.day
	# Check save data for finished important emails
	var finished_important_emails: Array[EmailData] = Global.finished_important_emails
	# Check save data for read emails
	var read_emails: Array[EmailData] = Global.read_emails
	# Check save data for spam emails
	var spam_emails: Array[EmailData] = Global.spam_emails

	# Create email list items, and mark read or unread
	email_app_list_items = []
	for email_data in emails_to_populate:
		var is_email_finished_important: bool = false
		if email_data in finished_important_emails:
			is_email_finished_important = true
	
		var is_email_read: bool = false
		if email_data in read_emails:
			is_email_read = true
	
		var is_current_day: bool = false
		if current_day == email_data.day_to_send:
			is_current_day = true
			
		var is_finished_spam: bool = false
		if email_data in spam_emails:
			is_finished_spam = true
	
		var email_app_list_item: EmailAppListItem = email_app_list_item_packed_scene.instantiate()
		email_app_list_item.initialize(email_data, is_email_finished_important, is_email_read, is_current_day, is_finished_spam) 
		email_app_list_items_container.add_child(email_app_list_item, true)
		email_app_list_items_container.move_child(email_app_list_item, 0)
		email_app_list_item.email_pressed.connect(_on_email_pressed)
		email_app_list_items.append(email_app_list_item)

func _on_email_pressed(email_app_list_item: EmailAppListItem) -> void:
	var email_data: EmailData = email_app_list_item.email_data
	# Mark as read if unread
	if not email_app_list_item.is_read:
		Global.read_emails.append(email_data)
		email_app_list_item.mark_as_read()
	# Open the email in the viewer
	_open_email_in_viewer(email_app_list_item)

func _open_email_in_viewer(email_app_list_item: EmailAppListItem) -> void:
	# Check current day
	var current_day: int = Global.day
	var is_current_day: bool = false
	if current_day == email_app_list_item.email_data.day_to_send:
		is_current_day = true
	
	email_viewer.visible = true
	email_viewer.show_email(email_app_list_item.email_data, email_app_list_item.is_finished_important, is_current_day, email_app_list_item.is_finished_spam)

func _on_finished_important_email(email_data: EmailData) -> void:
	for email_app_list_item in email_app_list_items:
		if email_app_list_item.email_data == email_data:
			email_app_list_item.mark_as_finished_important()
