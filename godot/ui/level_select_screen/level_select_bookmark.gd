class_name LevelSelectBookmark
extends Node3D

@export var _animation_player: AnimationPlayer
@export var _animation_name_swap_out: StringName
@export var _animation_name_swap_in: StringName
@export var _day_bookmark_nodes: Array[Node3D]

func play_animation_swap_out() -> void:
	_animation_player.play(_animation_name_swap_out)
	await _animation_player.animation_finished

func play_animation_swap_in(day: int) -> void:
	set_bookmark_no_animation(day)

	_animation_player.play(_animation_name_swap_in)
	await _animation_player.animation_finished

func set_bookmark_no_animation(day: int) -> void:
	if day <= 0 or day >= 6:
		return

	for i in range(_day_bookmark_nodes.size()):
		var day_bookmark_node: Node3D = _day_bookmark_nodes[i]
		if i + 1 == day:
			day_bookmark_node.visible = true
		else:
			day_bookmark_node.visible = false
