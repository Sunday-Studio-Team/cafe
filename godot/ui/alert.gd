## Used in ui.gd via exported uid, to minimize VRAM usage when not in use.
extends HBoxContainer

@export var alert_label: Label
@export var alert_sprite: AnimatedSprite2D
@export var icon: TextureRect
@export var star_fill: TextureProgressBar
@export var sign_label: Label

var alert_tween: Tween
