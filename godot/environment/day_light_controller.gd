extends Node

# gets the animation player
@export var day_light_cycle_animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animation_name : String = "DayLightCycleAnimation"
	day_light_cycle_animation_player.play(animation_name) # play and pause the designated animation
	day_light_cycle_animation_player.pause()
	day_light_cycle_animation_player.seek(0.0,true) # set it to 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Global.shift_started == false): # only set the value if the game started, otherwise the ratio is 1.0 at first and will pop to 0 when game starts
		return
	var animation_progress: float = Global.shift_progress_ratio
	day_light_cycle_animation_player.seek(animation_progress,true) # Set animation based on the ratio
