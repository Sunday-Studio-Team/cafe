extends Container

@onready var money_label: Label = $MoneyLabel

var notif_tween = null

#func _ready():
	#money_label.modulate = Color(Color.BLACK, 0)
	#
	
func show_notif_lose_money() -> void: 
	if notif_tween:
		notif_tween.kill()
		
	money_label.text = "🏦 -$3"
	money_label.add_theme_color_override("font_color", Color.RED)
	
	notif_tween = create_tween()
	notif_tween.tween_interval(2)
	notif_tween.tween_property(money_label, "modulate", Color(Color.RED, 0), 0.5)
		
func show_notif_gain_money() -> void: 
	if notif_tween:
		notif_tween.kill()
		
	money_label.text = "🏦 +$3"
	money_label.add_theme_color_override("font_color", Color.SEA_GREEN)
	
	notif_tween = create_tween()
	notif_tween.tween_interval(2)
	notif_tween.tween_property(money_label, "modulate", Color(Color.SEA_GREEN, 0), 0.5)
		
