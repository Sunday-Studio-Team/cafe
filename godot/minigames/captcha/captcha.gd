extends SubViewportContainer

@export var main_ordered: IngredientIconHolder
@export var liquid_ordered: IngredientIconHolder
@export var extra_ordered: IngredientIconHolder
@export var captcha: GridContainer
@export var submit_button: Button
@export var instructions: RichTextLabel
@export var drink_name: RichTextLabel
@export var player_thought: RichTextLabel
@export var entire_panel: PanelContainer
@export var shake_intensity: float = 10
@export var order_reminder: Control
@export var customer_sprite: Sprite2D
@export var remade_drink_sprite: TextureRect
@export var click_sound: AudioStreamPlayer
@export var correct_sound: AudioStreamPlayer
@export var wrong_sound: AudioStreamPlayer
@export var drag_instruction_arrow: Control

var ordered_drink: Drink
var main_text: String = "with the required ingredients"
var drink_customer: Customer


func _ready() -> void:
	drag_instruction_arrow.hide()
	
	for slot: IngredientIconHolder in captcha.get_children():
		slot.button.pressed.connect(
			func():
				click_sound.play(),
		)
	
	_start_minigame()


func _process(delta: float) -> void:
	# This is solely for testing purposes (running the minigame outside of main)
	if Global.ordered_drink_to_remake == null and Global.ordered_drink_customer == null:
		# Disable Global so we can use the mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Global.process_mode = Node.PROCESS_MODE_DISABLED


func _input(event: InputEvent) -> void:
	# This is what refreshes the made_drink texture if the player drops somewhere they're not supposed to now
	# Brings the sprite back on any left click release
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == false:
		remade_drink_sprite.texture = ordered_drink.icon



func populate_captcha() -> void:
	var captcha_slots_to_fill = captcha.get_children() as Array[IngredientIconHolder]

	# get the ingredients from the ordered drink and put them each in one of the
	# slots in the captcha
	for ingredient: Ingredient in [
		ordered_drink.main_ingredient,
		ordered_drink.liquid,
		ordered_drink.extra,
	]:
		if ingredient != null and ingredient.name != Ingredient.Ingredient_Label.NONE:
			var random_icon_holder: IngredientIconHolder = captcha_slots_to_fill.pick_random()
			random_icon_holder.ingredient = ingredient
			captcha_slots_to_fill.erase(random_icon_holder)

	# fill in the rest of the slots with random ingredients
	for captcha_icon: IngredientIconHolder in captcha_slots_to_fill:
		captcha_icon.ingredient = Global.ingredients.pick_random()


func populate_order_reminder() -> void:
	main_ordered.ingredient = ordered_drink.main_ingredient
	liquid_ordered.ingredient = ordered_drink.liquid
	if (ordered_drink.extra):
		extra_ordered.ingredient = ordered_drink.extra


# Pass the ordered_drink: Drink into here, then everything should work itself out
func get_ordered_drink(drink: Drink) -> void:
	ordered_drink = drink
	#drink_name.text = "You are making %s [color=gold]%s" % [
		#ordered_drink.singular_article,
		#ordered_drink.name,
	#]
	player_thought.text = "I need to make %s [color=gold]%s" % [
		ordered_drink.singular_article,
		ordered_drink.name,
	]
	remade_drink_sprite.texture = drink.icon


func verify_captcha() -> void:
	# non-static for ease of use, could change this!
	var ordered_ingredients = [
		ordered_drink.main_ingredient,
		ordered_drink.liquid,
		ordered_drink.extra,
	]

	for captcha_icon: IngredientIconHolder in captcha.get_children():
		if (
			(
				ordered_ingredients.any(
					func(x: Ingredient):
						return x == captcha_icon.ingredient,
				)
				!= captcha_icon.button.button_pressed
			)
		):
			shake_panel()
			wrong_sound.play()
			return
	
	entire_panel.visible = false
	remade_drink_sprite.visible = true
	drag_instruction_arrow.visible = Global.day == 0
	player_thought.text = "I need to give the customer their drink\n(by clicking and dragging)"
	
	# Matthew: Commented this V out so the user can drag the drink, if anything breaks check if this is why
	#mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	correct_sound.play()

	for slot: IngredientIconHolder in captcha.get_children():
		var scale_tween := create_tween()
		scale_tween.tween_property(slot, "offset_transform_scale", Vector2.ONE * 0.75, 0.025)
		scale_tween.tween_property(slot, "offset_transform_scale", Vector2.ONE, 0.025)

		await get_tree().create_timer(0.025).timeout

		var colour_tween := create_tween()
		colour_tween.tween_property(slot, "modulate", Color.GOLD, 0.05)
		colour_tween.tween_property(slot, "modulate", Color.WHITE, 0.05)

	await correct_sound.finished
	
	#_end_minigame()


func set_instructions(text: String) -> void:
	instructions.text = text


func set_submit_text(text: String) -> void:
	submit_button.text = text


func shake_panel() -> void:
	var panel_original_position: Vector2 = entire_panel.position
	var tween = entire_panel.create_tween()
	var shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)

	tween.tween_property(
		entire_panel,
		"position",
		entire_panel.position + shake_offset_target,
		0.025,
	)
	for i in range(10):
		shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)
		tween.chain().tween_property(
			entire_panel,
			"position",
			entire_panel.position + shake_offset_target,
			0.025,
		)

	tween.tween_property(entire_panel, "position", panel_original_position, 0.1)


func _start_minigame() -> void:
	order_reminder.visible = false
	set_instructions(main_text)
	
	var drink: Drink
	
	# The else blocks here should only happen if this scene is ran by itself (not in the main game)
	if(Global.ordered_drink_to_remake != null):
		drink = Global.ordered_drink_to_remake
	else:
		drink = Global.drinks.pick_random()
	get_ordered_drink(drink)
	
	if(Global.ordered_drink_customer != null):
		drink_customer = Global.ordered_drink_customer
		customer_sprite.texture = drink_customer.body.texture
	else:
		customer_sprite.texture = Global.customer_sprites.pick_random().sprite
		order_reminder.visible = true
		populate_order_reminder()
	
	populate_captcha()



func _end_minigame() -> void:
	# THIS FUNCTION IS CALLED BY THE `CustomerContainer` node!
	# Since the game should only end when giving the customer their drink now
	print("End remaking minigame")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Only really relevant when playing minigame scenes as standalone
	Events.minigame_end.emit()


func _on_submit_button_pressed() -> void:
	verify_captcha()
