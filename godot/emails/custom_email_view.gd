class_name CustomEmailView
extends Control

signal finished_important(custom_email_view: CustomEmailView)
signal finished_spam(custom_email_view: CustomEmailView)

var is_finished_important: bool
var pressed_spam_bool: bool

func init(email_data: EmailData, init_is_finished_important: bool, init_mark_finished_spam: bool) -> void:
	is_finished_important = init_is_finished_important
	pressed_spam_bool = init_mark_finished_spam

func mark_finished_important() -> void:
	is_finished_important = true
	finished_important.emit(self)
	
func mark_finished_spam() -> void:
	pressed_spam_bool = true
	finished_spam.emit(self)
