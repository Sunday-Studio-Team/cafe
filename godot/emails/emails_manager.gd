class_name EmailsManager
extends Node

static var _instance: EmailsManager

@export var emails_schedule: Array[EmailData]

var _delivered_emails_to_date: Array[EmailData]

static func get_instance() -> EmailsManager:
	return _instance

func _ready() -> void:
	_instance = self
	
	# Check current day
	var current_day: int = Global.day
	# Check emails schedule for all emails that are current day or beyond
	_delivered_emails_to_date = []
	for email_data in emails_schedule:
		var email_scheduled_day: int = email_data.day_to_send
		if current_day >= email_scheduled_day:
			_delivered_emails_to_date.append(email_data)

func get_delivered_emails_to_date() -> Array[EmailData]:
	return _delivered_emails_to_date

func has_unfinished_important_emails_to_date() -> bool:
	# Check save data for finished important emails
	var finished_important_emails: Array[EmailData] = Global.finished_important_emails
	for delivered_email in _delivered_emails_to_date:
		if !delivered_email.is_important:
			continue
		if delivered_email not in finished_important_emails:
			return true
	return false
	
