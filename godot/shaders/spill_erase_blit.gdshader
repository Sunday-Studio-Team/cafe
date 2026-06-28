shader_type texture_blit;
render_mode blend_mul;

uniform sampler2D source_texture0 : hint_blit_source0;

void blit() {
	float erase = texture(source_texture0, UV).a * MODULATE.a;
	float keep = clamp(1.0 - erase, 0.0, 1.0);
	COLOR0 = vec4(keep, keep, keep, keep);
}
