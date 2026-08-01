class_name SpamEmail
extends EmailData

const SPAM_SUBJECTS = [
	"You've won a prize!",
	"Claim your free gift now!",
	"Exclusive offer just for you!",
	"Don't miss out on this deal!",
	"Congratulations! You've been selected!",
    "YOU WON A FREE IPHONE!!!!"
]

const SPAM_CONTENTS = [
	"Congratulations! You've been selected to receive a special prize. Click the link below to claim it now!",
	"Don't miss out on this exclusive offer! Act fast before it's gone!",
	"You've won a free gift! Click here to claim it now!",
	"This is your last chance to claim your prize! Click the link below!",
    "Congratulations! You've been selected for a special reward. Click here to claim it!"
]

func _init():
	day_to_send = Global.day
	is_important = false
	sender_name = "Unknown"
	displayed_time = str(randi_range(8, 10)) + ":" + str(randi_range(0, 59)).pad_zeros(2) + "am"
	subject = SPAM_SUBJECTS[randi() % SPAM_SUBJECTS.size()]
	recipient_name = "Employee #000000"
	contents = SPAM_CONTENTS[randi() % SPAM_CONTENTS.size()]
	custom_email_view_packed_scene = load("res://emails/random_emails/custom_email_view_spam.tscn")
