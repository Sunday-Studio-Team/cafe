shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color;
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX * MODELVIEW_MATRIX) * NORMAL;
	vec2 offset = normalize(clip_normal.xy) * outline_width * clip_position.w / VIEWPORT_SIZE;

	clip_position.xy += offset * 2.0;
	POSITION = clip_position;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}