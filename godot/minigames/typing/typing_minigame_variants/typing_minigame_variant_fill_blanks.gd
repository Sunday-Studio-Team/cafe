class_name TypingMinigameVariantFillBlanks
extends TypingMinigameVariant

@export var contents: Array[TypingMinigameContentFillBlanks]

@export var prefilled_section_packed_scene: PackedScene
@export var typed_section_packed_scene: PackedScene

@export var customer_dialog_view: TypingMinigameCustomerDialogView
@export var instructions_container: Control
@export var instructions_display_duration: float = 0.1
@export var sentence_container: Control

@export_category("New UI Stuff")
@export var sato_expressions:Array[Texture2D]
@export var sato_container:TextureRect
@export var customer_container:TextureRect
@export var tippy_group:Control
@export var dialogue_box:MarginContainer
@export var dialogue_box_texture:TextureRect
@export var speech_bubble_texture: TextureRect
@export var vs_container: MarginContainer

@export_category("Audio")
@export var correct_sound:AudioStreamPlayer
@export var wrong_sound:AudioStreamPlayer

var _sentence: TypingMinigameContentFillBlanksSentence
var _prefilled_sections: Array[TypingMinigameVariantFillBlanksPrefilledSection]
var _typing_sections: Array[TypingMinigameSection]
var _active_typing_section_index: int

func start_minigame_variant(customer: Customer) -> void:
	sato_container.texture = sato_expressions.pick_random()
	instructions_container.visible = false
	if customer:
		customer_container.texture = customer.customer_sprite_resource.typing_minigame_portrait
	var tween := create_tween()
	tween.tween_property(sato_container,"offset_transform_position",Vector2(0,00),1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(vs_container,"offset_transform_position",Vector2(0,0),1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(customer_container,"offset_transform_position",Vector2(128,00),1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(
		func():
			var tween2 := create_tween()
			tween2.tween_property(tippy_group,"offset_transform_position",Vector2(0,0),0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween2.set_parallel(true)
			tween2.tween_property(dialogue_box,"offset_transform_position",Vector2(0,0),0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			
			var tween3 := create_tween()
			tween3.tween_property(speech_bubble_texture,"offset_transform_scale",Vector2(1,1),0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween3.set_parallel(true)
			tween3.tween_property(speech_bubble_texture,"offset_transform_rotation",0,1.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	).set_delay(0.5)
	# Get a random minigame content resource
	var typing_minigame_contents_index: int = randi_range(0, contents.size()-1)
	var typing_minigame_content: TypingMinigameContentFillBlanks = contents[typing_minigame_contents_index]
	
	## Get a random dialog with reply
	_sentence = typing_minigame_content.customer_dialog_and_player_replies.pick_random()		
	#var customer_dialog: String = _sentence.customer_dialog
#
	#customer_dialog_view.init(customer_dialog)
	#customer_dialog_view.play_dialog()
	#await customer_dialog_view.dialog_finished
	
	instructions_container.visible = true
	
	var instructions_timer: SceneTreeTimer = get_tree().create_timer(instructions_display_duration)
	await instructions_timer.timeout
	
	# Create sentence views
	for sentence_section_content in _sentence.sentence_sections:
		if sentence_section_content is TypingMinigameContentFillBlanksSentencePrefilledSection:
			var prefilled_section_content: TypingMinigameContentFillBlanksSentencePrefilledSection = sentence_section_content as TypingMinigameContentFillBlanksSentencePrefilledSection
			var prefilled_section: TypingMinigameVariantFillBlanksPrefilledSection = prefilled_section_packed_scene.instantiate()
			prefilled_section.init(prefilled_section_content.prefilled_section)
			_prefilled_sections.append(prefilled_section)
			sentence_container.add_child(prefilled_section)
		elif sentence_section_content is TypingMinigameContentFillBlanksSentenceTypedSection:
			var typed_section_content: TypingMinigameContentFillBlanksSentenceTypedSection = sentence_section_content as TypingMinigameContentFillBlanksSentenceTypedSection
			var typing_minigame_section: TypingMinigameSection = typed_section_packed_scene.instantiate()
			typing_minigame_section.init(typed_section_content.typed_section)
			typing_minigame_section.section_finished.connect(_on_section_finished)
			_typing_sections.append(typing_minigame_section)
			sentence_container.add_child(typing_minigame_section)
		else:
			printerr("Unhandled TypingMinigameContentFillBlanksSentenceSection type")
	
	_active_typing_section_index = 0
	_start_next_section()


func _start_next_section() -> void:
	var typing_minigame_section: TypingMinigameSection = _typing_sections[_active_typing_section_index]
	print("starting section")
	typing_minigame_section.typed_letter_correct.connect(func(): correct_sound.play())
	typing_minigame_section.typed_letter_wrong.connect(func(): wrong_sound.play())
	typing_minigame_section.start_section()


func _on_section_finished(finished_typing_minigame_section: TypingMinigameSection) -> void:
	_active_typing_section_index += 1
	if _active_typing_section_index < _typing_sections.size():
		_start_next_section()
	else:
		minigame_variant_finished.emit(self)
