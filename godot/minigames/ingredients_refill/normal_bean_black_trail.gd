extends Line2D


@export var MAX_LENGTH : int

var queue: Array
var bean: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bean= get_parent().get_parent()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos = bean.global_position
	queue.push_front(pos)
	if queue.size()> MAX_LENGTH:
		queue.pop_back()
	clear_points()
	
	for point in queue:
		add_point(point)
		
