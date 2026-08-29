extends Area3D


func _on_body_entered(body: Node3D) -> void:
	# Add logic for giving player points here too
	body.queue_free()
