class_name PlayerDetectionArea
extends Area3D

@export var popup_this_is_camera: PackedScene #tutorial popup that shows player the camera

signal player_entered_area(detection_area: PlayerDetectionArea)
signal player_exited_area(detection_area: PlayerDetectionArea)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D):
	if body is Player:
		player_entered_area.emit(self)


func _on_body_exited(body: Node3D):
	if body is Player:
		player_exited_area.emit(self)
		show_tutorial_this_is_camera() #checks within this function, whether its appropriate to show a tutorial


func show_tutorial_this_is_camera()-> void:
	if OS.has_feature("skip_popups"):
		return
	# janky way to make sure the popup tutorial does not show up while in a menu/minigame
	while (Global.in_ui):
		await get_tree().create_timer(0.25).timeout
		

	#await get_tree().create_timer(0.75).timeout #allows audio to play first
	if (Global.day == 2) and (Global.tutorial_show_camera == false):
		Global.tutorial_show_camera = true
		Global.in_tutorial_screen = true

		#hide tablet so it's not in the way.
		var tablet = get_parent().get_parent().find_child("Tablet")
		tablet.hide()

		#CHANGE POPUP HERE
		var popup = popup_this_is_camera.instantiate()
		add_child(popup)
		get_tree().paused = true # this kinda works but its janky

		var button = popup.get_node("NextButton")
		popup.move_to_front() #this was an attempt to fix issue, does not really do anything
		popup.process_mode = Node.PROCESS_MODE_ALWAYS

		button.pressed.connect(
			func():
				get_tree().paused = false
				popup.queue_free()
		)

		# TODO: add functionality to allow use of Esc
		# TODO: add functionality so that button makes popup disappear

		await popup.tree_exited #delays some code until event occurs
		tablet.show()
		Global.in_tutorial_screen = false #re enable pause
