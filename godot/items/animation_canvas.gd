extends CanvasLayer

enum STATE {
	USE_ITEM,
	PULL_ITEM,
	EQUIPPED_ITEM,
	NO_ITEM,
}

var current_state: STATE = STATE.NO_ITEM
var item_animation_name: String = ""

@onready var animated_sprite_2d = $Control/MarginContainer/SubViewportContainer/SubViewport/ItemAnimation


#Animated Sprite has all animations. Put the equipped item.
func _ready():
	#Add the signal here
	animated_sprite_2d.play("default")
	Events.play_item_animation.connect(play_animation)
	animated_sprite_2d.animation_finished.connect(
		func(): Events.viewmodel_animation_finished.emit()
	)


func _physics_process(_delta: float) -> void:
	if (
			animated_sprite_2d.frame == 21
			and animated_sprite_2d.animation == "use_hammer"
	):
		Events.hammer_animation_hit.emit()

	visible = not Global.in_ui


#NOTE: NEED TO FIX THE ANIMATION STATE MACHINE
#TEMPORARY FOR TESTING
func play_animation(animation_name: String):
	var animation_type: String = animation_name.substr(0, 3)
	print("Animation Type: ", animation_type)
	#Identifies the correct state
	match animation_type:
		"pul":
			current_state = STATE.PULL_ITEM
			item_animation_name = animation_name.substr(3)
		"use":
			current_state = STATE.USE_ITEM
			item_animation_name = animation_name.substr(3)
		"equ":
			current_state = STATE.EQUIPPED_ITEM
			item_animation_name = animation_name.substr(3)
		_:
			current_state = STATE.NO_ITEM
			item_animation_name = ""

	animated_sprite_2d.play(animation_name)


# Checks for when the animation finishes
func _on_animated_sprite_2d_animation_finished():
	print("State: ", current_state)
	if item_animation_name == "":
		return

	match current_state:
		STATE.USE_ITEM:
			current_state = STATE.NO_ITEM
			play_animation("default")
		STATE.PULL_ITEM:
			play_animation("equ" + item_animation_name)
			current_state = STATE.EQUIPPED_ITEM
