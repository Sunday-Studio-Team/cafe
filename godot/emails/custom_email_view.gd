class_name CustomEmailView
extends Control

signal finished_important(custom_email_view: CustomEmailView)

var is_finished_important: bool

func init(email_data: EmailData, init_is_finished_important: bool) -> void:
	is_finished_important = init_is_finished_important

func mark_finished_important() -> void:
	is_finished_important = true
	finished_important.emit(self)
