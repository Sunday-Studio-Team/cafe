extends RigidBody2D

var time_counter_float: float = 0.0
@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D

var seconds_passed: float = 0.0
var is_bomb: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_child("Sprite2D").scale *=1.1
	var collision: CollisionShape2D = find_child("CollisionShape2D")
	collision.scale *=1.1
	collision.set_deferred("disabled", true)
	await get_tree().create_timer(0.25).timeout
	collision.set_deferred("disabled", false)
	animation_player.play("flash")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:

	sprite_2d.rotation_degrees += 6
	seconds_passed+=delta
	if(is_bomb):
		gravity_scale *= 1.009
		return
