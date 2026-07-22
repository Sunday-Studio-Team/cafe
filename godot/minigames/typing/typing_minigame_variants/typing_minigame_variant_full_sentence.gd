class_name TypingMinigameVariantFullSentence
extends TypingMinigameVariant

@export var contents: Array[TypingMinigameContentFullSentence]

@export var customer_dialog_view: TypingMinigameCustomerDialogView
@export var instructions_container: Control
@export var instructions_display_duration: float = 0.1
@export var typing_minigame_section: TypingMinigameSection


func start_minigame_variant(customer: Customer) -> void:
	instructions_container.visible = false
	typing_minigame_section.visible = false
	
	# Get a random minigame content resource
	var typing_minigame_contents_index: int = randi_range(0, contents.size()-1)
	var typing_minigame_content: TypingMinigameContentFullSentence = contents[typing_minigame_contents_index]
	
	# Get a random customer dialog
	var typing_minigame_content_customer_dialog_index: int = randi_range(0, typing_minigame_content.possible_customer_dialog.size()-1)
	var customer_dialog: String = typing_minigame_content.possible_customer_dialog[typing_minigame_content_customer_dialog_index]
	
	# Get a random player reply
	var typing_minigame_content_player_reply_index: int = randi_range(0, typing_minigame_content.possible_player_replies.size()-1)
	var player_reply: String = typing_minigame_content.possible_player_replies[typing_minigame_content_player_reply_index]
	
	customer_dialog_view.init(customer_dialog)
	customer_dialog_view.play_dialog()
	await customer_dialog_view.dialog_finished
	
	instructions_container.visible = true
	
	var instructions_timer: SceneTreeTimer = get_tree().create_timer(instructions_display_duration)
	await instructions_timer.timeout
	
	typing_minigame_section.init(player_reply)
	typing_minigame_section.section_finished.connect(_on_section_finished)
	typing_minigame_section.visible = true
	typing_minigame_section.start_section()

func _on_section_finished(finished_typing_minigame_section: TypingMinigameSection) -> void:
	minigame_variant_finished.emit(self)
