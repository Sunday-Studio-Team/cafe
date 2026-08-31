class_name PC_UI
extends Control

@export var email_button: Button
@export var shop_button: Button
@export var email_app: PCApp
@export var shop_app: PCApp
@export var exit_button: Button
## regular game hud
@export var ui: CanvasLayer
@export var irl_new_shop_items_indicator: Label3D
@export var unread_label:Label
@export var click_sound: AudioStreamPlayer
var new_shop_items := true


func _ready() -> void:
	email_button.pressed.connect(_on_email_button_pressed)
	shop_button.pressed.connect(_on_shop_button_pressed)
	exit_button.pressed.connect(exit)

	# Wait until everything else is ready, as main needs to set per day stuff.
	await get_tree().process_frame

	set_unread_count()
	
	# connecting all click sounds to any buttons that show up in the pc
	for button: Button in find_children("*", "Button"):
		button.pressed.connect(
			func():
				if not button == exit_button:
					click_sound.play()
		)
	
	email_app.email_viewer.email_shown.connect(
		func(email_viewer):
			if email_viewer.active_custom_email_view != null:
				for button: TextureButton in email_viewer.active_custom_email_view.find_children("*", "TextureButton"):
					button.pressed.connect(
						func():
							click_sound.play()
					)
	)
		
	for email_app_list_item in email_app.email_app_list_items:
		email_app_list_item.email_pressed.connect(
			func(email_app_list_item):
				click_sound.play()
		)


func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause") and Global.in_pc_ui):
		var in_app := false

		for app in [email_app, shop_app]:
			if app.visible:
				in_app = true

		if not in_app:
			exit()

	#irl_new_shop_items_indicator.visible = new_shop_items and not Global.day < 2

	Global.in_pc_ui = visible


func exit() -> void:
	email_app.hide()
	shop_app.hide()
	hide()


func _on_email_button_pressed() -> void:
	email_app.show()


func _on_shop_button_pressed() -> void:
	shop_app.show()
	new_shop_items = false


func set_unread_count():
	unread_label.visible = false
	unread_label.text = str(Global.unread_email_count)
	if Global.unread_email_count != 0:
		unread_label.visible = true
