shader_type spatial;

uniform vec3 full_color : source_color;
uniform vec3 empty_color : source_color;
uniform float radius;
uniform float progress : hint_range(0.0, 1.0);

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 centered = UV - 0.5;
	if (length(centered) > radius) {
	        discard;
	}
	
	float angle = fract(atan(centered.x, -centered.y) / TAU);
	if (angle < progress) {
		discard;
	}
	
	ALBEDO = mix(full_color, empty_color, progress);
}

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
