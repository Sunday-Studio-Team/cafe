extends CharacterBody2D

@export var speed = 400

#Prevents movement while player is not in minigame
var active_movement : bool = true

func get_input():
	if active_movement:
		var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()



func _on_area_2d_body_entered(body):
	print("body ", body)
	pass # Replace with function body.


func _on_area_2d_area_entered(area):
	#Check if 
	print("area ", area)
	if area.name == "Goal":
		print("Goal")
	pass # Replace with function body.
