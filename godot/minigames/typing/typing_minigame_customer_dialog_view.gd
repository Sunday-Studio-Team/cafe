class_name TypingMinigameCustomerDialogView
extends Control

signal dialog_finished(typing_minigame_customer_dialog_view: TypingMinigameCustomerDialogView)

@export var customer_dialog_rich_text_label: RichTextLabel
@export var customer_dialog_text_tween_duration: float = 0.2

func init(customer_dialog: String) -> void:
	customer_dialog_rich_text_label.text = customer_dialog


func play_dialog() -> void:
	var customer_dialog_tween: Tween = create_tween()
	customer_dialog_rich_text_label.visible_characters = 0
	customer_dialog_tween.tween_property(customer_dialog_rich_text_label, "visible_characters", customer_dialog_rich_text_label.text.length(), customer_dialog_text_tween_duration)
	await customer_dialog_tween.finished
	dialog_finished.emit(self)
