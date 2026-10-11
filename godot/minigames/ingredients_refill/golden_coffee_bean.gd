extends RigidBody2D

var time_counter_float: float = 0.0
@export var sprite_2d: Sprite2D

var seconds_passed: float = 0.0
var is_gold: bool = false
var has_sped_up: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_child("Sprite2D").scale *=1.1
	var collision: CollisionShape2D = find_child("CollisionShape2D")
	collision.scale *=1.1
	collision.set_deferred("disabled", true)
	await get_tree().create_timer(0.25).timeout
	collision.set_deferred("disabled", false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
var drop_time = 0.674
func _physics_process(delta: float) -> void:
	if(seconds_passed>2): #prevents jitter
		if(get_collision_mask_value(1) == false): 
			set_collision_mask_value(1, true)
		return
	time_counter_float += delta
	seconds_passed+= delta
	if seconds_passed < drop_time:
		gravity_scale = 0
		sprite_2d.offset.y = 30 * sin(Engine.get_physics_frames() * 0.2)
		has_sped_up = true
	else:
		sprite_2d.rotation_degrees += 15
		if not offset_tween and sprite_2d.offset.y != 0:
			offset_tween = create_tween()
			offset_tween.tween_property(sprite_2d,"offset", Vector2.ZERO,0.2)
		
		if gravity_scale == 0: gravity_scale = 0.5
		gravity_scale = clamp(gravity_scale*1.09,0.5,2)
var offset_tween:Tween
	
