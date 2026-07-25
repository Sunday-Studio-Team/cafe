extends SubViewportContainer

@export var main_ordered: IngredientIconHolder
@export var liquid_ordered: IngredientIconHolder
@export var extra_ordered: IngredientIconHolder
@export var captcha: GridContainer
@export var submit_button: Button
@export var instructions: RichTextLabel
@export var drink_name: RichTextLabel
@export var entire_panel: PanelContainer
@export var shake_intensity: float = 10

var ordered_drink: Drink
var main_text: String = "The required ingredients"

func _ready() -> void:
	_start_minigame()


func _physics_process(delta: float) -> void:
	Global.making_drink_manually = true
	
	# Perform check for submit text every 10 frames because I dunno how expensive this is and something more complicated but more efficient seemed not that worth it
	if Engine.get_physics_frames() % 5 == 0:
		var button_is_selected: bool = false
		if captcha.get_children().any(func(x: IngredientIconHolder): return x.button.button_pressed):
			set_submit_text("VERIFY")
		else:
			set_submit_text("SKIP")

func populate_captcha() -> void:
	for captcha_icon: IngredientIconHolder in captcha.get_children():
		captcha_icon.button.button_pressed = false
		captcha_icon.ingredient = Global.ingredients.pick_random()
	
	# Functionality to guarantee needed icons show up at least once
	captcha.get_children().pick_random().ingredient = ordered_drink.main_ingredient
	captcha.get_children().pick_random().ingredient = ordered_drink.liquid
	if(ordered_drink.extra):
		captcha.get_children().pick_random().ingredient = ordered_drink.extra

func populate_order_reminder() -> void:
	main_ordered.ingredient = ordered_drink.main_ingredient
	liquid_ordered.ingredient = ordered_drink.liquid	
	if (ordered_drink.extra):
		extra_ordered.ingredient = ordered_drink.extra

# Pass the ordered_drink: Drink into here, then everything should work itself out
func get_ordered_drink(drink: Drink) -> void:
	ordered_drink = drink
	drink_name.text = "You are making %s [color=gold]%s" % [ordered_drink.singular_article, ordered_drink.name]
			

func verify_captcha() -> void:
	# non-static for ease of use, could change this!
	var ordered_ingredients = [
		ordered_drink.main_ingredient,
		ordered_drink.liquid,
		ordered_drink.extra
	]	
	
	for captcha_icon: IngredientIconHolder in captcha.get_children():
		if ( (ordered_ingredients.any(func(x: Ingredient): return x == captcha_icon.ingredient) != captcha_icon.button.button_pressed)):
			shake_panel()
			return
			
	_end_minigame()
	

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
	set_instructions(main_text)
	
	# Temp drink setting for testing
	var drink: Drink = Global.ordered_drink_to_remake
	get_ordered_drink(drink)
	
	populate_captcha()
	populate_order_reminder()


func _end_minigame() -> void:
	Global.making_drink_manually = false
	Events.minigame_end.emit()


func _on_submit_button_pressed() -> void:
	verify_captcha()
