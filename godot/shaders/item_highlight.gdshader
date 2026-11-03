shader_type spatial;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;
uniform bool use_texture = false;

uniform vec4 glow_color : source_color = vec4(0.2, 0.8, 1.0, 1.0); 
uniform float glow_intensity : hint_range(0.0, 10.0) = 4.0;

uniform float u_hover : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base_color = albedo;
    if (use_texture) {
        base_color *= texture(texture_albedo, UV);
    }
    
    ALBEDO = base_color.rgb;
	ALPHA = base_color.a;
	// hover is false, emission is 0 
    EMISSION = glow_color.rgb * glow_intensity * u_hover;
}