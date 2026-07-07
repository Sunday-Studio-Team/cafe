class_name TypingMinigame
extends Control

enum State {
	CUSTOMER_APOLOGY,
	INGREDIENTS_LIST,
	FINISHED,
}

@export var typing_minigame_variant_full_sentence_packed_scene: PackedScene
@export var typing_minigame_variant_fill_blanks_packed_scene: PackedScene
@export var typing_minigame_variant_ingredients_list_packed_scene: PackedScene

@export var typing_minigame_variant_container: Control

@export var full_sentence_likelihood: float = 1.0
@export var fill_blanks_likelihood: float = 0.0

var _state: State
var _active_typing_minigame_variant: TypingMinigameVariant
var _active_helpdesk_customer: Customer

func _ready() -> void:
	_start_minigame()


func _start_minigame() -> void:
	_state = State.CUSTOMER_APOLOGY
	
	_active_helpdesk_customer = Global.active_helpdesk_customer
	
	var customer_apology_typing_minigame_variant_packed_scene: PackedScene
	var likelihoods_total: float = full_sentence_likelihood + fill_blanks_likelihood
	var roll: float = randf_range(0.0, likelihoods_total)
	if roll <= full_sentence_likelihood and full_sentence_likelihood > 0.0:
		customer_apology_typing_minigame_variant_packed_scene = typing_minigame_variant_full_sentence_packed_scene
	else:
		customer_apology_typing_minigame_variant_packed_scene = typing_minigame_variant_fill_blanks_packed_scene
	
	var customer_apology_typing_minigame_variant: TypingMinigameVariant = customer_apology_typing_minigame_variant_packed_scene.instantiate()
	typing_minigame_variant_container.add_child(customer_apology_typing_minigame_variant)
	customer_apology_typing_minigame_variant.minigame_variant_finished.connect(_on_minigame_variant_finished)
	customer_apology_typing_minigame_variant.start_minigame_variant(_active_helpdesk_customer)
	_active_typing_minigame_variant = customer_apology_typing_minigame_variant


func _on_minigame_variant_finished(typing_minigame_variant: TypingMinigameVariant) -> void:
	match _state:
		State.CUSTOMER_APOLOGY:
			_active_typing_minigame_variant.queue_free()
			
			var ingredients_list_typing_minigame_variant: TypingMinigameVariant = typing_minigame_variant_ingredients_list_packed_scene.instantiate()
			typing_minigame_variant_container.add_child(ingredients_list_typing_minigame_variant)
			ingredients_list_typing_minigame_variant.minigame_variant_finished.connect(_on_minigame_variant_finished)
			ingredients_list_typing_minigame_variant.start_minigame_variant(_active_helpdesk_customer)
			_active_typing_minigame_variant = ingredients_list_typing_minigame_variant
			
			_state = State.INGREDIENTS_LIST
		State.INGREDIENTS_LIST:
			_active_typing_minigame_variant.queue_free()
			_finish_minigame()
		_:
			pass


func _finish_minigame() -> void:
	_state = State.FINISHED
	Events.minigame_end.emit()
