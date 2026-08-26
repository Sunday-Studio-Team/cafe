class_name EmailsManager
extends Node

static var _instance: EmailsManager

var _delivered_emails_to_date: Array[EmailData]

var last_spam_email_day: int = 0

static func get_instance() -> EmailsManager:
	return _instance

func _ready() -> void:
	_instance = self
	
	# Check current day
	var current_day: int = Global.day
	# Check when we've last gotten a random email
	var days_since_random = current_day - last_spam_email_day
	# Check emails schedule for all emails that are current day or beyond
	_delivered_emails_to_date = []
	
	# Needs to be added manually since can't be added to game resource bc it uses stats that are not initialized until after the game resource is loaded
	# if not Global.ai_improvement and current_day >= 3:
	# 	var email_day_3 = EmailDay3.new()
	# 	Global.emails_schedule.append(email_day_3)
		
	## check for menu updates
	if Global.drinks.any(func(d: Drink): return d.day_unlocked == current_day) and current_day > 1:
		Global.emails_schedule.append(MenuUpdateEmail.new())
		
	## get reviews
	if current_day >= 2:
		var review_count = randi_range(0, 4)
		for i in range(review_count):
			var review = Global.reviews.filter(func(x: Review): return not x in Global.recieved_reviews).pick_random()
			Global.recieved_reviews[review] = current_day
		if review_count >= 1:
			Global.emails_schedule.append(ReviewUpdateEmail.new())
	
	if days_since_random >= 2: # Can't get random emails everyday or on first day
		var min_random = 0.1
		for i in range(1, days_since_random): # More likely to get random emails the more days have passed
			min_random += 0.1
		var rand_email_percent = randf_range(min_random, 1.0)
		if rand_email_percent >= 0.5:
			last_spam_email_day = current_day
			var spam_email = SpamEmail.new()
			Global.emails_schedule.append(spam_email)				

	for email_data in Global.emails_schedule:
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
	
