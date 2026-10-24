class_name TypingMinigame
extends Control

enum State {
	CUSTOMER_APOLOGY,
	INGREDIENTS_LIST,
	FINISHED,
}

@export var _minigame_startup_overlay: MinigameStartupOverlay

@export var typing_minigame_variant_fill_blanks_packed_scene: PackedScene

@export var typing_minigame_variant_container: Control

@export var full_sentence_likelihood: float = 1.0
@export var fill_blanks_likelihood: float = 0.0

@export var timer_progress_bar: TextureProgressBar

var percent_time_left: float
var _state: State
var _active_typing_minigame_variant: TypingMinigameVariant
var _active_helpdesk_customer: Customer

func _ready() -> void:
	if Global.active_help_desk_customer != null:
		percent_time_left = Global.active_help_desk_customer.timer.time_left
	
	_minigame_startup_overlay.play("TYPE!")
	_start_minigame()

func _process(delta: float) -> void:
	if Global.active_help_desk_customer != null:
		percent_time_left = Global.active_help_desk_customer.timer.time_left
		if percent_time_left >= 30:
			timer_progress_bar.modulate = Color.GREEN
		elif percent_time_left >= 15:
			timer_progress_bar.modulate = Color.ORANGE
		else:
			timer_progress_bar.modulate = Color.RED
		timer_progress_bar.value = percent_time_left 

func _start_minigame() -> void:
	_state = State.CUSTOMER_APOLOGY
	
	_active_helpdesk_customer = Global.active_help_desk_customer
	
	var typing_minigame_scene: TypingMinigameVariant = typing_minigame_variant_fill_blanks_packed_scene.instantiate()
	typing_minigame_variant_container.add_child(typing_minigame_scene)
	typing_minigame_scene.minigame_variant_finished.connect(_on_minigame_variant_finished)
	typing_minigame_scene.start_minigame_variant(_active_helpdesk_customer)
	_active_typing_minigame_variant = typing_minigame_scene


func _on_minigame_variant_finished() -> void:
	match _state:
		State.CUSTOMER_APOLOGY:
			_active_typing_minigame_variant.queue_free()

			_finish_minigame()
		_:
			pass


func _finish_minigame() -> void:
	_state = State.FINISHED
	Events.minigame_end.emit()
