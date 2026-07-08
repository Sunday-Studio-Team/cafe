extends Resource

class_name Recipe

enum Step1 {milk, water, no_base}
enum Step2 {green_tea, black_tea, matcha, coffee}
var ice: bool
var sugar: bool
var boba: bool
var Step3: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
