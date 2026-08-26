class_name EmailsManager
extends Node

static var _instance: EmailsManager

@export var _intro_email: EmailData

var last_spam_email_day: int = 0

static func get_instance() -> EmailsManager:
	return _instance

func _ready() -> void:
	_instance = self

func deliver_emails() -> void:	
	# Check current day
	var current_day: int = Global.day
	# Check when we've last gotten a random email
	var days_since_random = current_day - last_spam_email_day
	
	var emails_to_deliver: Array[EmailData]
	
	if Global.day == 1:
		emails_to_deliver.append(_intro_email)
	
	## check for menu updates
	if Global.drinks.any(func(d: Drink): return d.day_unlocked == current_day) and current_day > 1:
		emails_to_deliver.append(MenuUpdateEmail.new())
	
	## get reviews
	if current_day >= 2:
		var reviews_to_add: Array[Review]
		var review_count = randi_range(1, 4)
		for i in range(review_count):
			var review = Global.reviews.filter(func(x: Review): return not x in Global.received_reviews).pick_random()
			if review == null:
				printerr("Not enough reviews for us to work with!")
				break
			Global.received_reviews.append(review)
			reviews_to_add.append(review)
		if review_count >= 1:
			var reviews_update_email_data: ReviewsUpdateEmailData = ReviewsUpdateEmailData.new()
			reviews_update_email_data.email_reviews = reviews_to_add
			emails_to_deliver.append(reviews_update_email_data)
	
	if days_since_random >= 2: # Can't get random emails everyday or on first day
		var min_random = 0.1
		for i in range(1, days_since_random): # More likely to get random emails the more days have passed
			min_random += 0.1
		var rand_email_percent = randf_range(min_random, 1.0)
		if rand_email_percent >= 0.5:
			last_spam_email_day = current_day
			var spam_email = SpamEmail.new()
			emails_to_deliver.append(spam_email)
	
	for email_data in emails_to_deliver:
		var email_scheduled_day: int = email_data.day_to_send
		if current_day >= email_scheduled_day:
			Global.received_emails.append(email_data)

func has_unfinished_important_emails_to_date() -> bool:
	# Check save data for finished important emails
	var finished_important_emails: Array[EmailData] = Global.finished_important_emails
	for received_email in Global.received_emails:
		if !received_email.is_important:
			continue
		if received_email not in finished_important_emails:
			return true
	return false
	
