extends EmailData
class_name MenuUpdateEmail

var opener_list = [
	"According to our AI-powered reasearch assisstant, our menu is lacking...",
	"Our current menu is not making us enough money.",
	"The other cafes have a menu far superior to ours."
]
var description_list = [
	"But that ends today.",
	"We might need to circle back on this, but for now, we have a fix.",
	"The solution to this is honestly low-hanging fruit."
]
var closer_list = [
	"This is where the rubber meets the road.",
	"This should move the needle on our numbers.",
	"With this, we should hit the ground running."
]
func _init():
	var scene_loader = load("res://emails/menu_update_emails/custom_email_view_menu_update.tscn")
	var scene: CustomEmailViewMenuUpdate = scene_loader.instantiate() as CustomEmailViewMenuUpdate
	day_to_send = Global.day
	is_important = true
	sender_name = "Management"
	displayed_time = "8:30am"
	subject = "Important: Menu Update"
	recipient_name = "Employee #000000"
	custom_email_view_packed_scene = scene_loader
	contents += "Hi all,\n\n"	
	contents += opener_list.pick_random() + "\n\n"
	contents += description_list.pick_random() + "\n\nThat's why we're adding these new menu items.\n\n"
	contents += closer_list.pick_random() + "\nGood luck."
