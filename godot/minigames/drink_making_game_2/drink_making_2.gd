extends SubViewportContainer

@export var main_ordered: IngredientIconHolder
@export var liquid_ordered: IngredientIconHolder
@export var extra_ordered: IngredientIconHolder
@export var captcha: GridContainer
@export var submit_button: Button
@export var instructions: RichTextLabel
@export var entire_panel: PanelContainer
@export var shake_intensity: float = 10

var main_icons: Dictionary[Drink.MainIngredient, Texture2D] = Global.main_ingredient_icons
var liquid_licons: Dictionary[Drink.Liquid, Texture2D] = Global.liquid_icons
var extra_icons: Dictionary[Drink.Extra, Texture2D] = Global.extra_icons
var ordered_drink: Drink
var current_game_state: GameStates = GameStates.MAIN
var main_text: String = "The required first ingredient"
var liquid_text: String = "The required second ingredient"
var extra_text: String = "The required third ingredient"

enum GameStates {MAIN, LIQUID, EXTRA}

func _ready() -> void:
	_start_minigame()


func _physics_process(delta: float) -> void:
	# Perform check for submit text every 10 frames because I dunno how expensive this is and something more complicated but more efficient seemed not that worth it
	if Engine.get_physics_frames() % 5 == 0:
		var button_is_selected: bool = false
		for captcha_icon: IngredientIconHolder in captcha.get_children():
			if captcha_icon.button.button_pressed:
				button_is_selected = true
				break
		if button_is_selected:
			set_submit_text("VERIFY")
		else:
			set_submit_text("SKIP")


func populate_captcha() -> void:
	for captcha_icon: IngredientIconHolder in captcha.get_children():
		captcha_icon.button.button_pressed = false
		match current_game_state:
			GameStates.MAIN:
				var ingredient_num: Drink.MainIngredient = Global.main_ingredient_icons.keys().pick_random()
				captcha_icon.type = captcha_icon.Type.MAIN
				captcha_icon.ingredient = ingredient_num
			GameStates.LIQUID:
				var ingredient_num: Drink.Liquid = Global.liquid_icons.keys().pick_random()
				captcha_icon.type = captcha_icon.Type.LIQUID
				captcha_icon.ingredient = ingredient_num
			GameStates.EXTRA:
				var ingredient_num: Drink.Extra = Global.extra_icons.keys().pick_random()
				captcha_icon.type = captcha_icon.Type.EXTRA
				captcha_icon.ingredient = ingredient_num
	# TODO: Add functionality to guarantee needed icon shows up at least once


func populate_order_reminder() -> void:
	main_ordered.ingredient = ordered_drink.main_ingredient
	liquid_ordered.ingredient = ordered_drink.liquid
	extra_ordered.ingredient = ordered_drink.extra


# Pass the ordered_drink: Drink into here, then everything should work itself out
func get_ordered_drink(drink: Drink) -> void:
	ordered_drink = drink


## Should only be called after verifying that criteria for progressing state is met
func progress_state() -> void:
	match current_game_state:
		GameStates.MAIN:
			current_game_state = GameStates.LIQUID
			populate_captcha()
			set_instructions(liquid_text)
		GameStates.LIQUID:
			current_game_state = GameStates.EXTRA
			populate_captcha()
			set_instructions(extra_text)
		GameStates.EXTRA:
			_end_minigame() 


func verify_captcha() -> void:
	# non-static for ease of use, could change this!
	var ordered_ingredient
	match current_game_state:
		GameStates.MAIN:
			ordered_ingredient = ordered_drink.main_ingredient
		GameStates.LIQUID:
			ordered_ingredient = ordered_drink.liquid
		GameStates.EXTRA:
			ordered_ingredient = ordered_drink.extra
	
	for captcha_icon: IngredientIconHolder in captcha.get_children():
		if ( (captcha_icon.ingredient == ordered_ingredient) != captcha_icon.button.button_pressed ):
			shake_panel()
			return
	
	progress_state()


func set_instructions(text: String) -> void:
	instructions.text = text


func set_submit_text(text: String) -> void:
	submit_button.text = text


func shake_panel() -> void:
	var panel_original_position: Vector2 = entire_panel.position
	var tween = entire_panel.create_tween()
	var shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)
	
	tween.tween_property(entire_panel, "position", entire_panel.position+shake_offset_target, 0.025)
	for i in range(10):
		shake_offset_target = Vector2(randf_range(-shake_intensity, shake_intensity), 0)
		tween.chain().tween_property(entire_panel, "position", entire_panel.position+shake_offset_target, 0.025)
	
	tween.tween_property(entire_panel, "position", panel_original_position, 0.1)



func _start_minigame() -> void:
	current_game_state = GameStates.MAIN
	set_instructions(main_text)
	
	# Temp drink setting for testing
	var drink: Drink = Global.drinks.pick_random()
	get_ordered_drink(drink)
	
	populate_captcha()
	populate_order_reminder()


func _end_minigame() -> void:
	print("End drink minigame 2")
	Events.minigame_end.emit()


func _on_submit_button_pressed() -> void:
	verify_captcha()
