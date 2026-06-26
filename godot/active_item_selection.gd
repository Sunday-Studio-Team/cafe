@tool
extends Control

const SPRITE_SIZE = Vector2(32,32)

@export var bkg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

@export var options = []

var selection : int = 0



#Need to use to resize
func _ready():
	pass

func _draw():
	var offset = SPRITE_SIZE / -2
	
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
	
	if len(options) >= 3:
		for i in range(len(options)-1):
			#Calculates how much the circle will be divided by
			var rads = TAU * i / ((len(options)-1))
			#Turns the radian into a point at the edge of the created circle
			var point = Vector2.from_angle(rads)
			#Draws line from edge of center circle to end of circle
			draw_line(
				point*inner_radius,
				point*outer_radius,
				line_color,
				line_width,
				true
				)
		
		#If selection is inner circle. If not, will draw highlight below in the arc draw
		if selection == 0:
			draw_circle(Vector2.ZERO, inner_radius, highlight_color)
			
			
		#Insert draw tool sprite here
			
		#Draws the image based on the 
		for i in range(1, len(options)):
			var start_rads = (TAU *(i-1)) / (len(options) - 1)
			var end_rads = (TAU * i) / (len(options) - 1)
			var mid_rads = (start_rads + end_rads) / 2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2
			
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
				
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer,
					PackedColorArray([highlight_color])
				)
			
			
				
			

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			print("Selection: ", selection)

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
	
	queue_redraw()
