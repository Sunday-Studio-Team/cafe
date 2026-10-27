shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// default is st to 1.0 pixel more
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	
	float object_color = texture(TEXTURE, UV).a;
	
	// depend on the number of pixels to span around the object
	float alpha = texture(TEXTURE, UV + vec2(size.x, 0.0)).a +
	              texture(TEXTURE, UV + vec2(-size.x, 0.0)).a +
	              texture(TEXTURE, UV + vec2(0.0, size.y)).a +
	              texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
				  
	alpha = min(alpha, 1.0);
	
	vec4 final_color = texture(TEXTURE, UV);
	
	// ignore anything that is the object itslf and only look at points in empty space
	if (object_color == 0.0 && alpha > 0.0) {
		final_color = outline_color;
		final_color.a = alpha;
	}
	
	COLOR = final_color;
}
