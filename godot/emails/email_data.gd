class_name EmailData
extends Resource

@export var day_to_send: int
@export var is_important: bool
@export var sender_name: String
@export var displayed_time: String
@export var subject: String
@export var recipient_name: String
@export_multiline var contents: String
@export var custom_email_view_packed_scene: PackedScene
