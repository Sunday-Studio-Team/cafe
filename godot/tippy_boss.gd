extends Node3D

@export var nav_agent: NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	nav_agent.target_position = Global.player.global_position

	global_position = global_position.move_toward(nav_agent.get_next_path_position(), delta)
