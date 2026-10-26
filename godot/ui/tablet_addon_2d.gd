extends MarginContainer

const FIRST_DAY_WITH_REMAKE_RULE: int = 3
const FIRST_DAY_WITH_RUNNING_RULE: int = 4
const RED_COLOR: Color = Color("6d0000")
const GREEN_COLOR: Color = Color("225619")

@export_category("Nodes")
@export var background: ColorRect
@export var eye_meter: TextureProgressBar
@export var no_remaking_icon: TextureRect
@export var no_running_icon: TextureRect

@export_category("Assets")
@export var eye_meter_over_caught_texture: Texture
@export var eye_meter_over_uncaught_texture: Texture
@export var remake_rule_icon_texture_green: Texture
@export var remake_rule_icon_texture_red: Texture
@export var running_rule_icon_texture_green: Texture
@export var running_rule_icon_texture_red: Texture


func _ready():
	no_remaking_icon.visible = Global.day >= FIRST_DAY_WITH_REMAKE_RULE
	no_running_icon.visible = Global.day >= FIRST_DAY_WITH_RUNNING_RULE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# its silly but we have to cos the var we're checking gets set to false
	# every physics frame BEFORE we'd be checking it here
	await get_tree().process_frame

	# TODO: replace with real alert meter logic
	if Global.player_in_cctv_los:
		eye_meter.value = 100
	else:
		eye_meter.value = 0

	if eye_meter.value == 100:
		background.color = RED_COLOR
		eye_meter.texture_over = eye_meter_over_caught_texture
		no_remaking_icon.texture = remake_rule_icon_texture_red
		no_running_icon.texture = running_rule_icon_texture_red
	else:
		background.color = GREEN_COLOR
		eye_meter.texture_over = eye_meter_over_uncaught_texture
		no_remaking_icon.texture = remake_rule_icon_texture_green
		no_running_icon.texture = running_rule_icon_texture_green
