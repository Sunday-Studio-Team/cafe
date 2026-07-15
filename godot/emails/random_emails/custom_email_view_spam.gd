extends CustomEmailView
class_name CustomEmailViewSpam

@onready var claim_button: Button = $TextureRect/ClaimButton

func _ready() -> void:
	claim_button.pressed.connect(_on_button_pressed)
	_update_button()
	
func _on_button_pressed() -> void:
	mark_spam_pressed()

	var scam_chance = randf_range(0.2, 1.0)
	if scam_chance >= 0.5:
		Global.bank_money += -3
	else:
		Global.bank_money += 3
		
	_update_button()
	
func _update_button() -> void:
	claim_button.disabled = pressed_spam_bool
	if pressed_spam_bool:
		claim_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		claim_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
