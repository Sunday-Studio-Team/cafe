extends Node

@export var cup_area: Area2D
@export var cup: CharacterBody2D
@export var water_pour_point: Marker2D
@export var milk_pour_point: Marker2D
@export var tea_pour_point: Marker2D
@export var green_tea_pour_point: Marker2D
@export var black_tea_pour_point: Marker2D
@export var chai_pour_point: Marker2D
@export var matcha_pour_point: Marker2D
@export var ice_spawn_point: Marker2D
@export var sugar_spawn_point: Marker2D

var recipe_list: Array[Recipe] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
#PLAN FOR THE MINIGAME
#set pour points down for each ingredient, have step 2/3 be invisible
#toggle visibility based on step, give score at the end based on matching ingredients to recipe class
#score determines customer satisfaction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
