extends Control

@export var main_ordered: IngredientIconHolder
@export var liquid_ordered: IngredientIconHolder
@export var extra_ordered: IngredientIconHolder
@export var captcha: GridContainer
@export var entire_panel: Control
@export var shake_intensity: float = 10
@export var order_reminder: Control
@export var customer_sprite: TextureRect
@export var customer_arrival_notify: TextureRect
@export var remade_drink_sprite: TextureRect
@export var click_sound: AudioStreamPlayer
@export var correct_sound: AudioStreamPlayer
@export var wrong_sound: AudioStreamPlayer
@export var ice_freezing_sound: AudioStreamPlayer

@export var req_and_sel:TextureRect
@export var captcha_vbox:VBoxContainer
@export var sato_tippy_fight:TextureRect
@export var complete_sprite:TextureRect
@export var sato:TextureRect
@export var frozen_border: TextureRect
@export var remake_drink_button: TextureButton
@export var remake_drink_button_ready: Texture2D
@export var remake_drink_button_not_ready: Texture2D

enum SatoTippyFight {
	Neutral = 0,
	Win = 1,
	Loss = 2,
	WinFirstTry = 3
}
@export var sato_tippy_textures:Array[Texture2D]
@export var sato_sprites:Array[Texture2D]

@export var drink_name: RichTextLabel

var ordered_drink: Drink
var drink_customer: Customer
var previous_drink_wrong: bool = false
var drop_finished: bool = true
var notify_tween: Tween

func _ready() -> void:
	for slot: IngredientIconHolder in captcha.get_children():
		slot.button.pressed.connect(
			func():
				click_sound.play(),
		)
		
	var mat = remade_drink_sprite.material as ShaderMaterial

	mouse_entered.connect(func():
		mat.set_shader_parameter("outline_width", 8.0)
		print("mouse outline made")
	)
	
	mouse_exited.connect(func():
		mat.set_shader_parameter("outline_width", 0.0)
		print("mouse outline removed")
	)
	remade_drink_sprite.drink_drop.connect(_on_drink_drag_ended)
	
	for slot: IngredientIconHolder in captcha.get_children():
		slot.button.pressed.connect(
			func():
				click_sound.play()
				_update_ingredient_count_state()
		)
	_play_notify()
	_start_minigame()

func _process(_delta: float) -> void:
	# This is solely for testing purposes (running the minigame outside of main)
	if Global.ordered_drink_to_remake == null and Global.ordered_drink_customer == null:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Global.process_mode = Node.PROCESS_MODE_DISABLED


func _on_drink_drag_ended(dragged_item: TextureRect) -> void:	
	print("_on_drink_drag_ended called")

	if dragged_item != null:
		print("dragged_item is available")
	else:
		print("WARNING: ordered_drink or icon is null!")
	
	var current_position = dragged_item.global_position
	dragged_item.global_position = remade_drink_sprite.global_position
	
	var tween = dragged_item.create_tween()
	tween.tween_property(dragged_item, "rotation", TAU * 0.25, 0.1)
	tween.tween_property(dragged_item, "rotation", TAU * 0.50, 0.1)
	tween.tween_property(dragged_item,	"rotation", TAU * 0.75, 0.1) 
	tween.tween_property(dragged_item,	"rotation", TAU * 1.00, 0.1) 
	
	if dragged_item.global_position == current_position:
		drop_finished = true
	
func _input(event: InputEvent) -> void:
	# This is what refreshes the made_drink texture if the player drops somewhere they're not supposed to now
	# Brings the sprite back on any left click release
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == false and drop_finished == true:
		remade_drink_sprite.texture = ordered_drink.icon
		drop_finished = false

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

	var drink_str:String = ""
	var drink_arr:PackedStringArray = ordered_drink.name.to_upper().split(" ")
	for i in range(drink_arr.size()):
		if i == 2 and drink_arr.size() >= 4: drink_str += "[br]"
		drink_str += str(drink_arr[i], " ")
	drink_name.text = str("[font_size=100][color=black][center]%s" % drink_str).strip_edges()
	remade_drink_sprite.texture = drink.icon


func on_wrong():
	sato.texture = sato_sprites[SatoTippyFight.Loss]
	sato_tippy_fight.texture = sato_tippy_textures[SatoTippyFight.Loss]

	var base_pos = customer_sprite.position
	var jump_tween = create_tween()
	jump_tween.tween_property(customer_sprite, "position:y", base_pos.y - 40.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(customer_sprite, "position:y", base_pos.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	var shake_tween = create_tween()
	
	#number of pixels to shift the character
	var intensity = 12.0
	
	# 6 x 0.05 seconds spread out; 0.3 seconds total time for shake
	for i in range(6):
		
		var direction = 1
		if i % 2 != 0:
			direction = -1
			
		var target_x = base_pos.x + (intensity * direction)
		shake_tween.tween_property(customer_sprite, "position:x", target_x, 0.05)
		
	shake_tween.tween_property(customer_sprite, "position:x", base_pos.x, 0.05)

	await get_tree().create_timer(1).timeout
	sato.texture = sato_sprites[SatoTippyFight.Neutral]
	sato_tippy_fight.texture = sato_tippy_textures[SatoTippyFight.Neutral]
	
func on_right():
	req_and_sel.visible = false
	captcha_vbox.visible = false
	complete_sprite.visible = true
	sato.texture = sato_sprites[SatoTippyFight.Win]
	sato_tippy_fight.texture = sato_tippy_textures[SatoTippyFight.Win]
	
	# Tell the tutorial the captcha part is done
	Global.tutorial_drink_remake_ingredients_done = true

func on_right_first_try():
	req_and_sel.visible = false
	captcha_vbox.visible = false
	complete_sprite.visible = true
	sato.texture = sato_sprites[SatoTippyFight.WinFirstTry]
	sato_tippy_fight.texture = sato_tippy_textures[SatoTippyFight.Win]
	
	# Tell the tutorial the captcha part is done
	Global.tutorial_drink_remake_ingredients_done = true


func verify_captcha() -> void:
	# non-static for ease of use, could change this!
	var ordered_ingredients: Array[Variant] = [
		ordered_drink.main_ingredient,
		ordered_drink.liquid,
		ordered_drink.extra,
	]
	
	# not counting duplicates, so if our drink has coffee, and we select 3 coffees,
	# that will only add 1 to this count
	var correct_ingredients_pressed: int = 0
	
	for ingredient: Ingredient in ordered_ingredients:
		if (
			captcha.get_children().any(
					func(slot: IngredientIconHolder):
						if ingredient == null:
							return true
						return slot.ingredient == ingredient and slot.button.button_pressed
		)
	):
			correct_ingredients_pressed += 1
		
	var wrong_ingredients_pressed: int = 0

	for slot: IngredientIconHolder in captcha.get_children():
		if slot.button.button_pressed and not ordered_ingredients.has(slot.ingredient):
			wrong_ingredients_pressed += 1
			
	if correct_ingredients_pressed == ordered_ingredients.size() and wrong_ingredients_pressed == 0 and previous_drink_wrong == true:
		on_right()
		remade_drink_sprite.show()
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
	elif correct_ingredients_pressed == ordered_ingredients.size() and wrong_ingredients_pressed == 0 and previous_drink_wrong == false:
		on_right_first_try()
		remade_drink_sprite.show()
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
	else:
		previous_drink_wrong = true
		on_wrong()
		shake_panel()
		wrong_sound.play()


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
	sato_tippy_fight.texture = sato_tippy_textures[SatoTippyFight.Neutral]
	var drink: Drink
	
	# The else blocks here should only happen if this scene is ran by itself (not in the main game)
	if(Global.ordered_drink_to_remake != null):
		drink = Global.ordered_drink_to_remake
	else:
		drink = Global.drinks.pick_random()
		
	get_ordered_drink(drink)
	
	if(Global.ordered_drink_customer != null):
		drink_customer = Global.ordered_drink_customer

		var texture_to_use: Texture = null
		if drink_customer.customer_sprite_resource.alternate_desk_sprite:
			texture_to_use = drink_customer.customer_sprite_resource.alternate_desk_sprite
		else:
			texture_to_use = drink_customer.full_body_sprite.texture
		customer_sprite.texture = texture_to_use

		rescale_image_to_target_height(customer_sprite)
	else:
		customer_sprite.texture = Global.customer_sprites.pick_random().sprite
		rescale_image_to_target_height(customer_sprite)
		# TODO: Unhide Ingredient Reminder for tutorial
		#order_reminder.visible = true
		populate_order_reminder()

	populate_captcha()

	var has_frozen_tippy_item: bool = Global.owned_items.any(
			func(item: Item) -> bool:
				return item.item_id == "barista_guide"
	)

	if has_frozen_tippy_item:
		ice_freezing_sound.play()
		var border_freeze_tween := create_tween().set_ignore_time_scale().set_ease(Tween.EASE_OUT)
		border_freeze_tween.tween_property(
				frozen_border, 
				"modulate", 
				Color.WHITE, 
				1
		)


func _play_notify() -> void:
	if not customer_arrival_notify:
		return
		
	customer_arrival_notify.visible = true
	customer_arrival_notify.modulate.a = 0.0
	
	var intro_tween = create_tween()
	intro_tween.tween_property(customer_arrival_notify, "modulate:a", 1.0, 0.2)
	intro_tween.tween_property(customer_arrival_notify, "modulate:a", 0.2, 0.2)
	intro_tween.tween_property(customer_arrival_notify, "modulate:a", 1.0, 0.2)
	intro_tween.tween_property(customer_arrival_notify, "modulate:a", 0.3, 0.2)
	intro_tween.tween_property(customer_arrival_notify, "modulate:a", 1.0, 0.2)
	intro_tween.tween_interval(0.3)
	
	intro_tween.tween_callback(func():
		if customer_arrival_notify == null: return
		notify_tween = create_tween().set_loops()
		notify_tween.tween_property(customer_arrival_notify, "modulate:a", 0.3, 0.9)
		notify_tween.tween_property(customer_arrival_notify, "modulate:a", 1.0, 0.9)
	)
	
func _end_minigame() -> void:
	# THIS FUNCTION IS CALLED BY THE `CustomerContainer` node!
	# Since the game should only end when giving the customer their drink now
	print("End remaking minigame")
	correct_sound.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Only really relevant when playing minigame scenes as standalone
	Events.minigame_end.emit()


func _on_submit_button_pressed() -> void:
	verify_captcha()


func rescale_image_to_target_height(sprite: TextureRect, target_height:int = 1024)->void:
	#target_height is generally close to 1024 though non exact
	
	# the original height includes transparent space above character hence
	var original_height = sprite.texture.get_height()
	
	print("customer position", sprite.position.y)
	
	var img_character = sprite.texture.get_image()
	if img_character.is_compressed(): 
		img_character.decompress()
		
	# according to godot documentation ".get_used_rect()" function takes into account
	# alpha channel and enables us to extract the objct's true height that is not empty space
	
	print("true height", float(img_character.get_used_rect().size.y))
	
	var height_diff = target_height - float(img_character.get_used_rect().size.y)
	
	print("height_diff", height_diff)
	
	# reposition shorter character as a function of character height
	sprite.position.y = sprite.position.y + (height_diff*1.0)
	
	#insted of hard coding use placeholder position for this
	print("sprite.position.y", sprite.position.y)
	
	# since only the character widths trult change, the remaining part for resizing can be kept
	var original_width = float(sprite.texture.get_width())
	var ratio = float(float(img_character.get_used_rect().size.y))/float(target_height) #ex 2048/1024 = 2
	var _image = sprite.texture.get_image()
	## var target_width = original_width
	_image.resize(int(round(original_width/ratio)), int(target_height), Image.INTERPOLATE_LANCZOS)
	var _texture: ImageTexture = ImageTexture.create_from_image(_image)
	sprite.texture= _texture
	print("rescaled customer sprite size",customer_sprite.texture.get_size())
	

func _update_ingredient_count_state() -> void:
	var total_ingredients_pressed: int = captcha.get_children().filter(
		func(slot: IngredientIconHolder) -> bool:
			return slot.ingredient != null and slot.button.button_pressed
	).size()

	if total_ingredients_pressed > 0:
		print("Ingredients selected: ", total_ingredients_pressed)
		remake_drink_button.texture_normal = remake_drink_button_ready
	else:
		print("No ingredients selected.")
		remake_drink_button.texture_normal = remake_drink_button_not_ready

		
