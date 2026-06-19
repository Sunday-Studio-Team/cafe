class_name EmailViewer
extends Control

@export var sender_name_label: Label
@export var subject_label: Label
@export var displayed_date_time_label: Label
@export var recipient_label: Label
@export var brief_contents_rich_text_label: RichTextLabel

var email_data: EmailData
var is_current_day: bool

func show_email(init_email_data: EmailData, init_is_current_day: bool) -> void:
	email_data = init_email_data
	is_current_day = init_is_current_day
	
	sender_name_label.text = email_data.sender_name
	subject_label.text = email_data.subject
	if is_current_day:
		# Show time only
		displayed_date_time_label.text = email_data.displayed_time
	else:
		# Show day only
		displayed_date_time_label.text = "x days ago"
	recipient_label.text = email_data.recipient_name
	brief_contents_rich_text_label.text = email_data.contents
