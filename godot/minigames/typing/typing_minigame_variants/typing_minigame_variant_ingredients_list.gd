class_name TypingMinigameVariantIngredientsList
extends TypingMinigameVariant

@export var fallback_drink: Drink
@export var fallback_recipe: TypingMinigameContentIngredientsListRecipe
@export var ingredients_list: TypingMinigameContentIngredientsList

@export var drink_name_label: Label
@export var instructions_container: Control
@export var instructions_display_duration: float = 0.1
@export var typing_minigame_section: TypingMinigameSection

var _recipe: TypingMinigameContentIngredientsListRecipe
var _current_ingredient_index: int

func start_minigame_variant(customer: Customer) -> void:
	instructions_container.visible = false
	typing_minigame_section.visible = false
	
	# Get the drink the customer wants
	var drink: Drink
	if customer != null and customer.desired_drink != null:
		drink = customer.desired_drink
	else:
		drink = fallback_drink
	
	# Get the recipe for it
	for list_recipe in ingredients_list.recipes:
		var recipe_drink: Drink = list_recipe.drink_resource
		if drink == recipe_drink:
			_recipe = list_recipe
			break
	if _recipe == null:
		_recipe = fallback_recipe
	
	drink_name_label.text = drink.name
	
	instructions_container.visible = true
	
	var instructions_timer: SceneTreeTimer = get_tree().create_timer(instructions_display_duration)
	await instructions_timer.timeout
	
	typing_minigame_section.section_finished.connect(_on_section_finished)
	typing_minigame_section.visible = true
	
	_show_next_ingredient()

func _show_next_ingredient() -> void:
	var next_ingredient_name: String = _recipe.ingredient_names[_current_ingredient_index]
	_start_section(next_ingredient_name)

func _start_section(ingredient_text: String) -> void:
	typing_minigame_section.init(ingredient_text)
	typing_minigame_section.start_section()

func _on_section_finished(finished_typing_minigame_section: TypingMinigameSection) -> void:
	_current_ingredient_index += 1
	if _current_ingredient_index < _recipe.ingredient_names.size():
		_show_next_ingredient()
	else:
		minigame_variant_finished.emit(self)
