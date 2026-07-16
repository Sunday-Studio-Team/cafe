extends CanvasLayer

@onready var lose_money_label: Label = $LoseMoneyLabel

var notif_tween = null
func show_notif() -> void: 
	var tween : Tween lose_money_label.
