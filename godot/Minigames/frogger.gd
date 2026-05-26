extends Node2D

@export var circle2: Node2D
@export var circle_list: Array[Node2D]

func _physics_process(delta):
	#circle2.rotate(1*delta)
	for circle in circle_list:
		circle.rotate(0.8*delta)
