extends Control

@export var background_panel: Control
@export var wires: Array[Control]
@export var wire_holder: CanvasLayer

var colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.PURPLE
]

func _ready() -> void:
	var linecount = randi_range(3, 6)

	
#Sends out needed information if the vicotry is achived.
func victory():
	await get_tree().create_timer(0.5, false).timeout
	Events.emit_signal("minigame_end")
