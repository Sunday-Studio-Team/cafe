class_name ItemLocker
extends Node3D

@export var interactable: Interactable
@export var item_locker_model: ItemLockerModel
@export var animation_player: AnimationPlayer
@export var shake_sound: AudioStreamPlayer3D


func _ready() -> void:
	# if we haven't beaten day 1
	# (we want to have the locker if we're replaying day 1 after beating it, but not before)
	if SaveDataManager.save_data.latest_unlocked_day <= 1:
		hide()
		process_mode = ProcessMode.PROCESS_MODE_DISABLED

	Global.item_locker = self

	Events.shift_started.connect(
			func() -> void:
				interactable.hide()
	)


func _physics_process(_delta: float) -> void:
	# this sound gets played by the attention grab animation and i think
	# this might be the only way to make it cut off properly if we interrupt
	# that . . .
	if not animation_player.is_playing() and shake_sound.playing:
		shake_sound.stop()
