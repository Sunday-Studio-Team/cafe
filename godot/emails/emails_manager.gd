class_name EmailsManager
extends Node

static var _instance: EmailsManager

@export var emails_schedule: Array[EmailData]

var _delivered_emails_to_date: Array[EmailData]

var last_random_email_day: int = 0

static func get_instance() -> EmailsManager:
	return _instance

func _ready() -> void:
	_instance = self
	
	# Check current day
	var current_day: int = Global.day
	# Check when we've last gotten a random email
	var days_since_random = current_day - last_random_email_day
	# Check emails schedule for all emails that are current day or beyond
	_delivered_emails_to_date = []

	for email_data in emails_schedule:
		var email_scheduled_day: int = email_data.day_to_send
		if current_day >= email_scheduled_day:
			_delivered_emails_to_date.append(email_data)
	
	if days_since_random >= 2: # Can't get random emails everyday
		var min_random = 0.1
		for i in range(0, days_since_random): # More likely to get random emails the more days have passed
			min_random += 0.1
		var rand_email_percent = randf_range(min_random, 1.0)
		if rand_email_percent >= 0.5:
			last_random_email_day = current_day
			var random_email = SpamEmail.new()
			_delivered_emails_to_date.append(random_email)					
			

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
	
