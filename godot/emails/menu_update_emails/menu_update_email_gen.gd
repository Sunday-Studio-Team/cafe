extends EmailData
class_name MenuUpdateEmail

func _init():
	var scene_loader = load("res://emails/menu_update_emails/custom_email_view_menu_update.tscn")
	var scene: CustomEmailViewMenuUpdate = scene_loader.instantiate() as CustomEmailViewMenuUpdate
	scene.populate_drinks()
	day_to_send = Global.day
	is_important = true
	sender_name = "Management"
	displayed_time = "7am"
	subject = "Important: Menu Update"
	recipient_name = "Employee #000000"
	custom_email_view_packed_scene = scene_loader
