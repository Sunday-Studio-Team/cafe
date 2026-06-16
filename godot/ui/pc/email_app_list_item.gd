class_name EmailAppListItem
extends Control

signal email_pressed(email_app_list_item: EmailAppListItem)

@export var button: Button
@export var sender_name_label: Label
@export var subject_label: Label
@export var displayed_date_time_label: Label
@export var brief_contents_rich_text_label: RichTextLabel
@export var unread_indicator: Control

var email_data: EmailData
var is_read: bool
var is_current_day: bool

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func initialize(init_email_data: EmailData, init_is_read: bool, init_is_current_day: bool) -> void:
	email_data = init_email_data
	is_read = init_is_read
	is_current_day = init_is_current_day
	
	sender_name_label.text = email_data.sender_name
	subject_label.text = email_data.subject
	if is_current_day:
		# Show time only
		displayed_date_time_label.text = email_data.displayed_time
	else:
		# Show day only
		displayed_date_time_label.text = "x days ago"	
	brief_contents_rich_text_label.text = email_data.contents
	
	_update_unread_indicator()

func mark_as_read() -> void:
	is_read = true
	_update_unread_indicator()

func _update_unread_indicator() -> void:
	unread_indicator.visible = not is_read

func _on_button_pressed():
	email_pressed.emit(self)
