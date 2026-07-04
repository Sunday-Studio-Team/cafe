extends Control

@export var email_button: Button
@export var shop_button: Button
@export var email_app: PCApp
@export var shop_app: PCApp
@export var exit_button: Button
## regular game hud
@export var ui: CanvasLayer
@export var irl_new_shop_items_indicator: Label3D

var new_shop_items := true


func _ready() -> void:
	email_button.pressed.connect(_on_email_button_pressed)
	shop_button.pressed.connect(_on_shop_button_pressed)
	exit_button.pressed.connect(
		func():
			email_app.hide()
			shop_app.hide()
			hide()
			ui.show()
	)
	visibility_changed.connect(
		func():
			if visible:
				Global.in_pc_ui = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Global.in_pc_ui = false
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)


func _physics_process(_delta: float) -> void:
	irl_new_shop_items_indicator.visible = new_shop_items and not Global.day == 1


func _on_email_button_pressed() -> void:
	email_app.show()


func _on_shop_button_pressed() -> void:
	shop_app.show()
	new_shop_items = false
