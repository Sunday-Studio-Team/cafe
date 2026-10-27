class_name DebugCustomerSpriteCycler
extends Node

@export var _customer_sprite_tex_rect: TextureRect
@export var _customer_sprites: Array[Texture2D]

@export var _name_label: Label

var _customer_sprite_index: int = 0

func _ready() -> void:
	_update_tex()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use_item"):
		_customer_sprite_index -= 1
		if _customer_sprite_index < 0:
			_customer_sprite_index = _customer_sprites.size() - 1
		_update_tex()
	
	if Input.is_action_just_pressed("interact"):
		_customer_sprite_index += 1
		if _customer_sprite_index > _customer_sprites.size() - 1:
			_customer_sprite_index = 0
		_update_tex()
	
	if Input.is_action_just_pressed("drop"):
		DisplayServer.clipboard_set("%s" % _customer_sprites.get(_customer_sprite_index).resource_path)
		print("copied to clipboard")

func _update_tex() -> void:
	_customer_sprite_tex_rect.texture = _customer_sprites.get(_customer_sprite_index)
	_name_label.text = _customer_sprites.get(_customer_sprite_index).resource_path
