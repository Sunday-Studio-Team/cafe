extends RigidBody2D

var time_counter_float: float = 0.0

var seconds_passed: float = 0.0
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
func _physics_process(delta: float) -> void:
	
	
	if(seconds_passed>2): #prevents jitter
		if(get_collision_mask_value(1) ==false): 
			set_collision_mask_value(1, true)
		return
	time_counter_float += delta
	
	seconds_passed+=delta
	if(linear_velocity.y>0 and has_sped_up == false):	
		gravity_scale*=2.5
		has_sped_up = true
	
	#elif
	if(time_counter_float>1.0/60.0): #currently, physics tick is at 60hz; 8/23/2026
		time_counter_float -=1.0/60.0
		gravity_scale+=0.07
