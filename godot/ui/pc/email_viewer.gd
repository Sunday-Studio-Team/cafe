class_name EmailViewer
extends Control

@export var sender_name_label: Label
@export var subject_label: Label
@export var displayed_date_time_label: Label
@export var recipient_label: Label
@export var brief_contents_rich_text_label: RichTextLabel
@export var custom_email_view_container: Control

var email_data: EmailData
var is_finished_important: bool
var is_finished_spam: bool
var is_current_day: bool
var active_custom_email_view: CustomEmailView

func show_email(init_email_data: EmailData, init_is_finished_important: bool, init_is_current_day: bool, init_is_finished_spam: bool) -> void:
	if active_custom_email_view != null:
		if active_custom_email_view.finished_important.is_connected(_on_active_custom_email_view_finished_important):
			active_custom_email_view.finished_important.disconnect(_on_active_custom_email_view_finished_important)
		if active_custom_email_view.finished_spam.is_connected(_on_active_custom_email_view_finish_spam):
			active_custom_email_view.finished_spam.disconnect(_on_active_custom_email_view_finish_spam)
		active_custom_email_view.queue_free()

	email_data = init_email_data
	is_finished_important = init_is_finished_important
	is_current_day = init_is_current_day
	is_finished_spam = init_is_finished_spam
	
	sender_name_label.text = email_data.sender_name
	subject_label.text = email_data.subject
	if is_current_day:
		# Show time only
		displayed_date_time_label.text = email_data.displayed_time
	else:
		var days_ago = Global.day - email_data.day_to_send
		if days_ago == 1:
			displayed_date_time_label.text = "1 day ago"
		else:
			displayed_date_time_label.text = str(days_ago) + " days ago"
	recipient_label.text = email_data.recipient_name
	brief_contents_rich_text_label.text = email_data.contents
	
	if email_data.custom_email_view_packed_scene != null:
		active_custom_email_view = email_data.custom_email_view_packed_scene.instantiate()
		active_custom_email_view.init(email_data, is_finished_important, is_finished_spam)
		custom_email_view_container.add_child(active_custom_email_view)
		active_custom_email_view.finished_important.connect(_on_active_custom_email_view_finished_important)
		active_custom_email_view.finished_spam.connect(_on_active_custom_email_view_finish_spam)
		
func _on_active_custom_email_view_finished_important(custom_email_view: CustomEmailView) -> void:
	active_custom_email_view.finished_important.disconnect(_on_active_custom_email_view_finished_important)
	Global.finished_important_emails.append(email_data)
	Events.finished_important_email.emit(email_data)

func _on_active_custom_email_view_finish_spam(custom_email_view: CustomEmailView) -> void:
	active_custom_email_view.finished_spam.disconnect(_on_active_custom_email_view_finish_spam)
	Global.spam_emails.append(email_data)
	Events.finished_spam_email.emit(email_data)
