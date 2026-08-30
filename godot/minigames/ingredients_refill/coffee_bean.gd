extends RigidBody2D

var time_counter_float: float = 0.0

var seconds_passed: float = 0.0
var is_gold: bool = false
var is_bomb: bool = false
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
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	if(is_bomb):
		time_counter_float +=delta
		if (time_counter_float >1/60):
			time_counter_float -=1/60
			gravity_scale+=0.03
		return
	
	
	
	if(seconds_passed>2): #prevents jitter 
		return
	
	time_counter_float += delta
	
	if(is_gold):
		seconds_passed+= delta
		if(seconds_passed>.4):
			gravity_scale+=1
		else:
			if (time_counter_float >1/60):
				time_counter_float -=1/60
				gravity_scale+=0.065

	else:
		seconds_passed+=delta
		time_counter_float += delta
		if(time_counter_float>1/60): #currently, physics tick is at 60hz; 8/23/2026
			time_counter_float -=1/60
			gravity_scale+=0.07
	pass
	
