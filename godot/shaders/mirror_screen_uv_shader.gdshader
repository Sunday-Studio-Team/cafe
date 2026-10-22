shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D mirror_albedo_tex: source_color;

void fragment() {
	vec2 reflected_screen_uv = vec2(-SCREEN_UV.x, SCREEN_UV.y);
	ALBEDO = texture(mirror_albedo_tex, reflected_screen_uv).rgb;
}
