class_name EmailAppListItem
extends Control

signal email_pressed(email_app_list_item: EmailAppListItem)

@export var button: Button
@export var sender_name_label: Label
@export var subject_label: Label
@export var displayed_date_time_label: Label
@export var brief_contents_rich_text_label: RichTextLabel
@export var unread_indicator: Control
@export var important_indicator: Control

var email_data: EmailData
var is_finished_important: bool
var is_read: bool
var is_current_day: bool
var is_finished_spam: bool


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


func initialize(init_email_data: EmailData, init_is_finished_important: bool, init_is_read: bool, init_is_current_day: bool, init_is_finished_spam: bool) -> void:
	email_data = init_email_data
	is_finished_important = init_is_finished_important
	is_read = init_is_read
	is_current_day = init_is_current_day
	is_finished_spam = init_is_finished_spam
	
	var sender_name_cut = email_data.sender_name.split("@")
	sender_name_label.text = sender_name_cut[0]
	subject_label.text = email_data.subject
	if is_current_day:
		# Show time only
		displayed_date_time_label.text = email_data.displayed_time
	else:
		# Show day only
		var days_ago = Global.day - email_data.day_to_send
		if days_ago == 1:
			displayed_date_time_label.text = "1 day ago"
		else:
			displayed_date_time_label.text = str(days_ago) + " days ago"

	brief_contents_rich_text_label.text = email_data.contents

	_update_unread_indicator()
	_update_important_indicator()


func mark_as_read() -> void:
	is_read = true
	_update_unread_indicator()
	Global.unread_email_count -=1


func mark_as_finished_important() -> void:
	is_finished_important = true
	_update_important_indicator()


func mark_as_finished_spam() -> void:
	is_finished_spam = true


func _update_unread_indicator() -> void:
	unread_indicator.visible = not is_read


func _update_important_indicator() -> void:
	var show_important_indicator: bool = email_data.is_important and not is_finished_important
	important_indicator.visible = show_important_indicator


func _on_button_pressed():
	email_pressed.emit(self)
